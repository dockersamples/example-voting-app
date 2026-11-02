// Vote worker: moves votes from Redis into Postgres.
//
// Reliability changes vs. the upstream sample (see docs/gamedays/):
//   1. At-least-once delivery. A vote is atomically moved from "votes" to
//      "votes:processing" (LMOVE) and only removed after Postgres confirms the
//      write. If the worker crashes mid-write, the vote is recovered on startup
//      instead of being lost. Writes are idempotent (upsert on voter id), so a
//      replayed vote is harmless.
//   2. Drain at full speed. The upstream loop slept 100 ms after *every* vote,
//      capping throughput at ~10 votes/s. Now it only sleeps when the queue is
//      empty.
//   3. Database errors trigger a reconnect, not a process crash.
using System;
using System.Data.Common;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using Newtonsoft.Json;
using Npgsql;
using StackExchange.Redis;

namespace Worker
{
    public class Program
    {
        const string Queue = "votes";
        const string Processing = "votes:processing";

        static readonly string DbConnString =
            Environment.GetEnvironmentVariable("DB_CONNECTION_STRING")
            ?? "Server=db;Username=postgres;Password=postgres;";
        static readonly string RedisHost =
            Environment.GetEnvironmentVariable("REDIS_HOST") ?? "redis";

        public static int Main(string[] args)
        {
            var pgsql = OpenDbConnection(DbConnString);
            var redisConn = OpenRedisConnection(RedisHost);
            var redis = redisConn.GetDatabase();
            var definition = new { vote = "", voter_id = "" };

            RecoverInFlight(redis);

            long processed = 0;
            while (true)
            {
                try
                {
                    if (!redisConn.IsConnected)
                    {
                        Console.WriteLine("Reconnecting Redis");
                        redisConn = OpenRedisConnection(RedisHost);
                        redis = redisConn.GetDatabase();
                        RecoverInFlight(redis);
                    }

                    // Atomically claim the oldest vote.
                    string json = redis.ListMove(Queue, Processing, ListSide.Left, ListSide.Right);
                    if (json == null)
                    {
                        Thread.Sleep(100);   // idle: queue is empty
                        KeepAlive(pgsql);
                        continue;
                    }

                    var vote = JsonConvert.DeserializeAnonymousType(json, definition);
                    UpdateVote(pgsql, vote.voter_id, vote.vote);

                    // Acknowledge only after the write is durable.
                    redis.ListRemove(Processing, json, 1);

                    if (++processed % 1000 == 0)
                        Console.WriteLine($"Processed {processed} votes");
                }
                catch (Exception ex) when (ex is DbException || ex is InvalidOperationException || ex is SocketException)
                {
                    // The claimed vote stays in votes:processing and is retried.
                    Console.Error.WriteLine($"Database error, reconnecting: {ex.Message}");
                    pgsql.Dispose();
                    pgsql = OpenDbConnection(DbConnString);
                    RecoverInFlight(redis);
                }
                catch (RedisException ex)
                {
                    Console.Error.WriteLine($"Redis error: {ex.Message}");
                    Thread.Sleep(1000);
                }
            }
        }

        // Put votes claimed by a previous (crashed) run back at the head of the queue.
        static void RecoverInFlight(IDatabase redis)
        {
            long recovered = 0;
            while (redis.ListMove(Processing, Queue, ListSide.Right, ListSide.Left) != RedisValue.Null)
                recovered++;
            if (recovered > 0)
                Console.WriteLine($"Recovered {recovered} in-flight vote(s)");
        }

        static void KeepAlive(NpgsqlConnection connection)
        {
            using var cmd = connection.CreateCommand();
            cmd.CommandText = "SELECT 1";
            cmd.ExecuteNonQuery();
        }

        private static NpgsqlConnection OpenDbConnection(string connectionString)
        {
            NpgsqlConnection connection;
            while (true)
            {
                try
                {
                    connection = new NpgsqlConnection(connectionString);
                    connection.Open();
                    break;
                }
                catch (Exception ex) when (ex is SocketException || ex is DbException)
                {
                    Console.Error.WriteLine("Waiting for db");
                    Thread.Sleep(1000);
                }
            }

            Console.Error.WriteLine("Connected to db");

            using var command = connection.CreateCommand();
            command.CommandText = @"CREATE TABLE IF NOT EXISTS votes (
                                        id VARCHAR(255) NOT NULL UNIQUE,
                                        vote VARCHAR(255) NOT NULL
                                    )";
            command.ExecuteNonQuery();
            return connection;
        }

        private static ConnectionMultiplexer OpenRedisConnection(string hostname)
        {
            while (true)
            {
                try
                {
                    // Use IP address to work around https://github.com/StackExchange/StackExchange.Redis/issues/410
                    var ipAddress = GetIp(hostname);
                    Console.Error.WriteLine($"Connecting to redis at {ipAddress}");
                    return ConnectionMultiplexer.Connect($"{ipAddress},abortConnect=false,connectRetry=5");
                }
                catch (Exception ex) when (ex is RedisConnectionException || ex is SocketException)
                {
                    Console.Error.WriteLine("Waiting for redis");
                    Thread.Sleep(1000);
                }
            }
        }

        private static string GetIp(string hostname)
            => Dns.GetHostEntryAsync(hostname)
                .Result
                .AddressList
                .First(a => a.AddressFamily == AddressFamily.InterNetwork)
                .ToString();

        // Idempotent: replaying the same vote (at-least-once delivery) is safe.
        private static void UpdateVote(NpgsqlConnection connection, string voterId, string vote)
        {
            using var command = connection.CreateCommand();
            command.CommandText = @"INSERT INTO votes (id, vote) VALUES (@id, @vote)
                                    ON CONFLICT (id) DO UPDATE SET vote = EXCLUDED.vote";
            command.Parameters.AddWithValue("@id", voterId);
            command.Parameters.AddWithValue("@vote", vote);
            command.ExecuteNonQuery();
        }
    }
}
