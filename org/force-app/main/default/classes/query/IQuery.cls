public interface IQuery {
    Iterable<SObject> execute();
    SObjectType getSObjectType();
}