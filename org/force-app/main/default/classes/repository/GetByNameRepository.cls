public interface GetByNameRepository {
    Iterable<SObject> getByName(String name);
}