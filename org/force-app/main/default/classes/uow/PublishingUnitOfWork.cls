public with sharing class PublishingUnitOfWork implements IPublisher, IUnitOfWork {
    private System.Savepoint savepoint;
    @TestVisible
    private List<ISubscriber> subscribers;
    private List<SObject> listOfNew;
    private Map<Id, SObject> listOfModified;
    private Map<Id, SObject> listOfDeleted;

    public PublishingUnitOfWork() {
        subscribers = new List<ISubscriber>();
        listOfNew = new List<SObject>();
        listOfModified = new Map<Id, SObject>();
        listOfDeleted = new Map<Id, SObject>();
    }

    public void subscribe(ISubscriber sub) {
        for (ISubscriber s : subscribers) {
            if (sub == s) {
                return;
            }
        }

        subscribers.add(sub);
    }

    public void unsubsribe(ISubscriber sub) {
        for (Integer i = 0; i < subscribers.size(); i++) {
            if (subscribers.get(i) == sub) {
                subscribers.remove(i);
                return;
            }
        }
    }

    public void notifyAll(SObjectEvent event) {
        if (subscribers.size() > 0) {
            for (ISubscriber sub : subscribers) {
                sub.refine(event);
            }
        }
    }

    public void registerOfNew(SObject obj) {
        listOfNew.add(obj);
        notifyAll(new SObjectEvent(SObjectEvent.EventType.CREATED, obj));   
    }

    public void registerOfModified(SObject obj) {
        listOfModified.put(obj.Id, obj);
        notifyAll(new SObjectEvent(SObjectEvent.EventType.MODIFIED, obj));
    }

    public void registerOfDeleted(SObject obj) {
        listOfDeleted.put(obj.Id, obj);
        notifyAll(new SObjectEvent(SObjectEvent.EventType.DELETED, obj));
    }

    public void commitWork() {
        savepoint = Database.setSavepoint();
        
        try {
            if (listOfNew.size() > 0) {
                insert listOfNew;
            }

            if (listOfModified.size() > 0) {
                update listOfModified.values();
            }

            if (listOfDeleted.size() > 0) {
                delete listOfDeleted.values();
            }

            listOfNew.clear();
            listOfModified.clear();
            listOfDeleted.clear();
        } catch (Exception e) {
            Database.rollback(savepoint);
        }
    }

    public void rollback() {
        Database.rollback(savepoint);
    }
}