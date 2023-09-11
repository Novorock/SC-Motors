public interface IPublisher {
    void subscribe(ISubscriber subscriber);
    void unsubsribe(ISubscriber subscriber);
    void notifyAll(SObjectEvent event);
}