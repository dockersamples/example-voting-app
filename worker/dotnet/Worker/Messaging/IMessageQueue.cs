using NATS.Client;
using Worker.Messaging.Messages;

namespace Worker.Messaging
{
    public interface IMessageQueue
    {
        IConnection CreateConnection();

        void Publish<TMessage>(TMessage message) where TMessage : Message;
    }
}