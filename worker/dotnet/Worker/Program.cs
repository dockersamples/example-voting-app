using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using Worker.Data;
using Worker.Entities;
using Worker.Messaging;
using Worker.Workers;

namespace Worker
{
    class Program
    {
        static void Main(string[] args)
        {
            var config = new ConfigurationBuilder()
                .AddJsonFile("appsettings.json")
                .AddEnvironmentVariables()
                .Build();

            var loggerFactory = new LoggerFactory()
                .AddConsole();

            var services = new ServiceCollection()
                .AddSingleton(loggerFactory)
                .AddLogging()
                .AddSingleton<IConfiguration>(config)
                .AddTransient<IVoteData, MySqlVoteData>()
                .AddTransient<IMessageQueue, MessageQueue>()
                .AddSingleton<QueueWorker>()
                .AddDbContext<VoteContext>(builder => builder.UseMySQL(config.GetConnectionString("VoteData")));

            var provider = services.BuildServiceProvider();
            var worker = provider.GetService<QueueWorker>();
            worker.Start();
        }
    }
}
