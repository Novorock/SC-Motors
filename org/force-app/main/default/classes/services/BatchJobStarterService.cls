public class BatchJobStarterService implements Database.Batchable<sObject> {
    private Database.Batchable<sObject> original;
    
    public BatchJobStarterService(Database.Batchable<sObject> instance) {
        original = instance;
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return original.start(bc);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        original.execute(bc, scope);
    }
    
    public void finish(Database.BatchableContext bc) {
        original.finish(bc);
    }
    
	@AuraEnabled
    public static Id executeBatchJob(String batchableClassName) {
        Database.Batchable<sObject> job = (Database.Batchable<sObject>) Type.forName(batchableClassName).newInstance();
        return Database.executeBatch(new BatchJobStarterService(job));
    }
}