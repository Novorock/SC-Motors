public with sharing class SObjectEvent {
    public enum EventType {CREATED, MODIFIED, DELETED}

    private EventType eventType;
    private SObject sObj;

    public SObjectEvent(EventType eventType, SObject sObj) {
        this.eventType = eventType;
        this.sObj = sObj;
    }

    public SObject getSObject() {
        return sObj;
    }

    public Boolean of(EventType type) {
        return type.equals(eventType);
    }
}