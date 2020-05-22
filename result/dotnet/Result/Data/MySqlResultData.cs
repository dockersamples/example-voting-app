using System.Linq;
using Dapper;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MySql.Data.MySqlClient;
using Result.Models;

namespace Result.Data
{
    public class MySqlResultData : IResultData
    {
        private readonly string _connectionString;
        private readonly ILogger _logger;

        public MySqlResultData(IConfiguration config, ILogger<MySqlResultData> logger)
        {
            _connectionString = config.GetConnectionString("ResultData");
            _logger = logger;
        }

        public ResultsModel GetResults()
        {
            var model = new ResultsModel();            
            using (var connection = new MySqlConnection(_connectionString))
            {                
                var results = connection.Query("SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote ORDER BY vote");
                if (results.Any(x => x.vote == "a"))
                {
                    model.OptionA = (int) results.First(x => x.vote == "a").count;
                }
                if (results.Any(x => x.vote == "b"))
                {
                    model.OptionB = (int) results.First(x => x.vote == "b").count;
                }
                model.VoteCount = model.OptionA + model.OptionB;
            }
            return model;
        }
    }
}
