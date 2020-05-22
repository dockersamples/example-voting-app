using System;

namespace Worker.Messaging.Messages
{
    public class VoteCastEvent : Message
    {
        public override string Subject { get { return MessageSubject; } }

        public string VoterId {get; set;}

        public string Vote {get; set; }

         public static string MessageSubject = "events.vote.votecast";
    }
}