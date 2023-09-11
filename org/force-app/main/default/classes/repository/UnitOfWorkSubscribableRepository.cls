public with sharing class UnitOfWorkSubscribableRepository implements ISubscriber, Repository {
    @TestVisible
    private SObjectType sObjectType;
    @TestVisible
    private Map<Id, SObject> elements;

    public UnitOfWorkSubscribableRepository(SObjectType sObjectType) {
        this.sObjectType = sObjectType;
        elements = new Map<Id, SObject>();
    }

    public void refine(SObjectEvent event) {
        SObject obj = event.getSObject();
        
        if (sObjectType == obj.getSObjectType()) {
            if (event.of(SObjectEvent.EventType.MODIFIED)) {
                modify(event.getSObject());
            } else if (event.of(SObjectEvent.EventType.DELETED)) {
                remove(event.getSObject());
            }
        }
    }

    public SObject getById(Id id) {
        return elements.get(id);
    }

    public List<SObject> getByName(String name) {
        List<SObject> iterable = new List<SObject>();
        if (sObjectType.getDescribe().fields.getMap().containsKey('name')) {
            for (SObject obj : elements.values()) {
                if (name.equals(obj.get('name'))) {
                    iterable.add(obj);
                }
            }    
        }

        return iterable;
    }

    public void add(SObject obj) {
        throw new UnsupportedOperationException();
    }

    public void modify(SObject obj) {
        if (obj.getSObjectType() == sObjectType) {
            if (obj.Id == null) {
                throw new IllegalArgumentException();
            }

            elements.put(obj.Id, obj);
        } else {
            throw new IllegalArgumentException();
        }
    }

    public void remove(SObject obj) {
        if (obj.getSObjectType() == sObjectType) {
            elements.remove(obj.Id);
        } else {
            throw new IllegalArgumentException();
        }
    }

    public void fetch(IQuery query) {
        if (query.getSObjectType() == sObjectType) {
            Iterator<SObject> iterator = ((Iterable<SObject>) query.execute()).iterator();

            while (iterator.hasNext()) {
                SObject obj = iterator.next();
                elements.put(obj.Id, obj);
            }
        } else {
            throw new IllegalArgumentException();
        }
    }

    public SObjectType getSObjectType() {
        return sObjectType;
    }
}