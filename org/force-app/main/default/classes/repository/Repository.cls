public interface Repository {
    SObject getById(Id id);
    void add(SObject obj);
    void modify(SObject obj);
    void remove(SObject obj);
    void fetch(IQuery query);
    SObjectType getSObjectType();
}