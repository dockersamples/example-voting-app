using System;
using System.Data.Common;
using System.Linq;
using System.Net.Sockets;
using System.Threading;
using Newtonsoft.Json;
using Npgsql;
using StackExchange.Redis;

namespace Worker
{
    public class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                var pgsql = OpenDbConnection();
                var redisConn = OpenRedisConnection();
                var redis = redisConn.GetDatabase();

                // Keep definition of command and sleep alive
                var definition = new { vote = "", voter_id = "" };

                while (true)
                {
                    // Slow down if not connected to database or redis
                    if (pgsql.State != System.Data.ConnectionState.Open)
                    {
                        Console.Error.WriteLine("Reconnecting to DB");
                        pgsql = OpenDbConnection();
                    }

                    string json = redis.ListRightPopLeftPush("votes", "processing");
                    if (json != null)
                    {
                        var vote = JsonConvert.DeserializeAnonymousType(json, definition);
                        Console.WriteLine($"Processing vote for '{vote.vote}' by '{vote.voter_id}'");
                        
                        // Execute update or insert
                        UpdateVote(pgsql, vote.voter_id, vote.vote);
                        redis.ListRemove("processing", json);
                    }
                    else
                    {
                        Thread.Sleep(100);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return 1;
            }
        }

        private static NpgsqlConnection OpenDbConnection()
        {
            NpgsqlConnection connection = null;

            while (connection == null)
            {
                try
                {
                    var host = Environment.GetEnvironmentVariable("POSTGRES_HOST") ?? "db";
                    var port = int.TryParse(Environment.GetEnvironmentVariable("POSTGRES_PORT"), out var p) ? p : 5432;
                    var user = Environment.GetEnvironmentVariable("POSTGRES_USER") ?? "postgres";
                    var password = Environment.GetEnvironmentVariable("POSTGRES_PASSWORD") ?? "postgres";
                    var database = Environment.GetEnvironmentVariable("POSTGRES_DB") ?? "postgres";
                    
                    var sslEnv = Environment.GetEnvironmentVariable("POSTGRES_SSL");
                    bool useSsl = sslEnv == "true" || sslEnv == "1" || (host != "db" && !string.IsNullOrEmpty(host));

                    var builder = new NpgsqlConnectionStringBuilder
                    {
                        Host = host,
                        Port = port,
                        Username = user,
                        Password = password,
                        Database = database,
                        SslMode = useSsl ? SslMode.Require : SslMode.Disable,
                        TrustServerCertificate = true, // Required for AWS RDS self-signed root CAs
                        Timeout = 15
                    };

                    connection = new NpgsqlConnection(builder.ConnectionString);
                    connection.Open();

                    var command = connection.CreateCommand();
                    command.CommandText = @"CREATE TABLE IF NOT EXISTS votes (
                                                id VARCHAR(255) NOT NULL UNIQUE,
                                                vote VARCHAR(255) NOT NULL
                                            )";
                    command.ExecuteNonQuery();
                }
                catch (SocketException)
                {
                    Console.Error.WriteLine("Waiting for DB connection (SocketException)...");
                    Thread.Sleep(1000);
                }
                catch (DbException ex)
                {
                    Console.Error.WriteLine($"Waiting for DB connection (DbException): {ex.Message}");
                    Thread.Sleep(1000);
                }
            }

            Console.WriteLine("Connected to PostgreSQL");
            return connection;
        }

        private static ConnectionMultiplexer OpenRedisConnection()
        {
            ConnectionMultiplexer connection = null;

            while (connection == null)
            {
                try
                {
                    var host = Environment.GetEnvironmentVariable("REDIS_HOST") ?? "redis";
                    var port = int.TryParse(Environment.GetEnvironmentVariable("REDIS_PORT"), out var p) ? p : 6379;
                    var user = Environment.GetEnvironmentVariable("REDIS_USERNAME") ?? Environment.GetEnvironmentVariable("VALKEY_USER");
                    var password = Environment.GetEnvironmentVariable("REDIS_PASSWORD") ?? Environment.GetEnvironmentVariable("VALKEY_PASSWORD");
                   

		// Diagnostic logging
       		    Console.WriteLine("----- REDIS/VALKEY CREDENTIAL DIAGNOSTICS -----");
	            Console.WriteLine($"Host: {host}:{port}");
	            Console.WriteLine($"Raw User: '{(user ?? "NULL")}' (Length: {user?.Length ?? 0})");
        	    Console.WriteLine($"Raw Password: '{(password ?? "NULL")}' (Length: {password?.Length ?? 0})");
	            Console.WriteLine("------------------------------------------------");

         	    user = user?.Trim();
            	    password = password?.Trim();

	            var sslEnv = Environment.GetEnvironmentVariable("REDIS_SSL");
        	    bool useSsl = sslEnv == "true" || sslEnv == "1" || (host != "redis" && !string.IsNullOrEmpty(host));

	            if (string.IsNullOrEmpty(password))
	            {
        	        throw new InvalidOperationException("REDIS_PASSWORD is null or empty.");
	            }
 
                    var config = new ConfigurationOptions
                    {
                        EndPoints = { { host, port } },
			Password = password,
        	        Ssl = useSsl,
			SslHost = host, // Required: forces TLS SNI header to match the cluster DNS name
	                AbortOnConnectFail = true, // Fail fast so the catch block handles bad auth/timeout
                        ConnectTimeout = 10000,
                        SyncTimeout = 10000
                    };

// If the user is empty or "default", StackExchange.Redis expects User to be null
	            if (!string.IsNullOrEmpty(user) && user != "default")
            	    {
                	config.User = user;
            	    }
            	    else
	            {
                	config.User = null;
               	    }
                    // AWS ElastiCache Serverless / Valkey TLS certs
                    if (useSsl)
                    {
                        config.CertificateValidation += (sender, certificate, chain, errors) => true;
                    }

                    connection = ConnectionMultiplexer.Connect(config);
                }
                catch (Exception ex)
                {
		    Console.Error.WriteLine($"Waiting for Redis/Valkey: {ex.Message}");
	            connection = null;
                    Thread.Sleep(1000);
                }
            }

            Console.WriteLine("Connected to Redis/Valkey");
            return connection;
        }

        private static void UpdateVote(NpgsqlConnection connection, string voterId, string vote)
        {
            var command = connection.CreateCommand();
            try
            {
                command.CommandText = "INSERT INTO votes (id, vote) VALUES (@id, @vote)";
                AddNamedParameter(command, "id", voterId);
                AddNamedParameter(command, "vote", vote);
                command.ExecuteNonQuery();
            }
            catch (DbException)
            {
                command.CommandText = "UPDATE votes SET vote = @vote WHERE id = @id";
                command.ExecuteNonQuery();
            }
        }

        private static void AddNamedParameter(DbCommand command, string name, string value)
        {
            var parameter = command.CreateParameter();
            parameter.ParameterName = name;
            parameter.Value = value;
            command.Parameters.Add(parameter);
        }
    }
}

