using Microsoft.EntityFrameworkCore;

namespace Worker.Entities
{
    public class VoteContext : DbContext
    {
        private static bool _EnsureCreated;
        public VoteContext(DbContextOptions options) : base(options)
        {
            if (!_EnsureCreated)
            {
                Database.EnsureCreated();
                _EnsureCreated = true;
            }
        }

        public DbSet<Vote> Votes { get; set; }
    }
}
