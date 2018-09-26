using System.Timers;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Configuration;
using Result.Data;
using Result.Hubs;

namespace Result.Timers
{
    public class PublishResultsTimer
    {        
        private readonly IHubContext<ResultsHub> _hubContext;
        private readonly IResultData _resultData;
        private readonly Timer _timer;

        public PublishResultsTimer(IHubContext<ResultsHub> hubContext, IResultData resultData, IConfiguration configuration)
        {
            _hubContext = hubContext;
            _resultData = resultData;
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
            var model = _resultData.GetResults();
            _hubContext.Clients.All.SendAsync("UpdateResults", model);
        }
    }
}
