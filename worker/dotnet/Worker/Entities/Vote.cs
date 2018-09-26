using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Worker.Entities
{
    [Table("votes")]
    public class Vote
    {
        [Column("id")]
        [Key]
        public string VoterId { get; set; }

        [Column("vote")]
        public string VoteOption { get; set; }
    }
}
