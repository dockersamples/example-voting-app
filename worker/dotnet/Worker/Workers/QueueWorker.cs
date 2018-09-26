using System;
using System.Threading;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using NATS.Client;
using Worker.Data;
using Worker.Messaging;
using Worker.Messaging.Messages;

namespace Worker.Workers
{
    public class QueueWorker
    {
        private static ManualResetEvent _ResetEvent = new ManualResetEvent(false);
        private const string QUEUE_GROUP = "save-handler";

        private readonly IMessageQueue _messageQueue;
        private readonly IConfiguration _config;
        private readonly IVoteData _data;
        protected readonly ILogger _logger;

        public QueueWorker(IMessageQueue messageQueue, IVoteData data, IConfiguration config, ILogger<QueueWorker> logger)
        {
            _messageQueue = messageQueue;
            _data = data;
            _config = config;
            _logger = logger;
        }

        public void Start()
        {       
            _logger.LogInformation($"Connecting to message queue url: {_config.GetValue<string>("MessageQueue:Url")}");
            using (var connection = _messageQueue.CreateConnection())
            {
                var subscription = connection.SubscribeAsync(VoteCastEvent.MessageSubject, QUEUE_GROUP);
                subscription.MessageHandler += SaveVote;
                subscription.Start();
                _logger.LogInformation($"Listening on subject: {VoteCastEvent.MessageSubject}, queue: {QUEUE_GROUP}");

                _ResetEvent.WaitOne();
                connection.Close();
            }
        }

        private void SaveVote(object sender, MsgHandlerEventArgs e)
        {
            _logger.LogDebug($"Received message, subject: {e.Message.Subject}");
            var voteMessage = MessageHelper.FromData<VoteCastEvent>(e.Message.Data);
            _logger.LogInformation($"Processing vote for '{voteMessage.Vote}' by '{voteMessage.VoterId}'");
            try
            {
                _data.Set(voteMessage.VoterId, voteMessage.Vote);
                _logger.LogDebug($"Succesffuly processed vote by '{voteMessage.VoterId}'");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Vote processing FAILED for '{voteMessage.VoterId}', exception: {ex}");
            }
            
        }
    }
}