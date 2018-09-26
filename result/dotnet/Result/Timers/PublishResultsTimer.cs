using System;
using System.Timers;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Configuration;
using Result.Hubs;
using Result.Models;

namespace Result.Timers
{
    public class PublishResultsTimer
    {        
        private readonly IHubContext<ResultsHub> _hubContext;
        private readonly Timer _timer;
        //TODO- temp
        private static Random _Random = new Random();

        public PublishResultsTimer(IHubContext<ResultsHub> hubContext, IConfiguration configuration)
        {
            _hubContext = hubContext;
            var publishMilliseconds = configuration.GetValue<int>("ResultsTimer:PublishMilliseconds");
            _timer = new Timer(publishMilliseconds)
            {
                Enabled = false
            };
            _timer.Elapsed += PublishResults;
        }

        public void Start()
        {
            if (!_timer.Enabled)
            {
                _timer.Start();
            }
        }

        private void PublishResults(object sender, ElapsedEventArgs e)
        {
            var model = new ResultsModel
            {
                OptionA = _Random.Next(0, 100),
                OptionB = _Random.Next(0, 100)                
            };
            model.VoteCount = model.OptionA + model.OptionB;
            _hubContext.Clients.All.SendAsync("UpdateResults", model);
        }
    }
}
