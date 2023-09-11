public interface IUnitOfWork {
    void registerOfNew(SObject obj);
    void registerOfModified(SObject obj);
    void registerOfDeleted(SObject obj);
    void commitWork();
    void rollback();
}