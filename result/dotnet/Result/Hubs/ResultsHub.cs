using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Result.Models;

namespace Result.Hubs
{
    public class ResultsHub : Hub
    {
        public async Task UpdateResults(ResultsModel results)
        {
            await Clients.All.SendAsync("UpdateResults", results);
        }
    }
}
