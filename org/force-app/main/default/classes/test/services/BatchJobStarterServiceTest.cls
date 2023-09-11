@IsTest
public class BatchJobStarterServiceTest implements Database.Batchable<sObject> {    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return new List<Contact>{
            new Contact(LastName='Test1'),
            new Contact(LastName='Test2'),
            new Contact(LastName='Test3')    
        };
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
    }
    
    public void finish(Database.BatchableContext bc) {
    }
    
    @IsTest
    private static void testExecuteBatchJob() {
        Test.startTest();
        BatchJobStarterService.executeBatchJob('BatchJobStarterServiceTest');
        Test.stopTest();
    }
}