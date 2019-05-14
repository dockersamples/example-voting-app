using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using NATS.Client;
using Vote.Messaging.Messages;

namespace Vote.Messaging
{
    public class MessageQueue : IMessageQueue
    {
        protected readonly IConfiguration _configuration;
        protected readonly ILogger _logger;

        public MessageQueue(IConfiguration configuration, ILogger<MessageQueue> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public void Publish<TMessage>(TMessage message)
            where TMessage : Message
        {
            using (var connection = CreateConnection())
            {
                var data = MessageHelper.ToData(message);
                connection.Publish(message.Subject, data);
            }
        }

        public IConnection CreateConnection()
        {
            var url = _configuration.GetValue<string>("MessageQueue:Url");
            return new ConnectionFactory().CreateConnection(url);
        }
    }
}
