using NATS.Client;
using Vote.Messaging.Messages;

namespace Vote.Messaging
{
    public interface IMessageQueue
    {
        IConnection CreateConnection();

        void Publish<TMessage>(TMessage message) where TMessage : Message;
    }
}