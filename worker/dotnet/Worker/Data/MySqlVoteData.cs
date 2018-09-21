using Microsoft.Extensions.Logging;
using Worker.Entities;

namespace Worker.Data
{
    public class MySqlVoteData : IVoteData
    {
        private readonly VoteContext _context;        
        private readonly ILogger _logger;

        public MySqlVoteData(VoteContext context, ILogger<MySqlVoteData> logger)
        {
            _context = context;
            _logger = logger;            
        }

        public void Set(string voterId, string vote)
        {
            var currentVote = _context.Votes.Find(voterId);
            if (currentVote == null)
            {
                _context.Votes.Add(new Vote
                {
                    VoterId = voterId,
                    VoteOption = vote
                });
            }
            else if (currentVote.VoteOption != vote)
            {
                currentVote.VoteOption = vote;
            }
            _context.SaveChanges();
        }
    }
}