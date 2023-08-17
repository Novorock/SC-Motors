@IsTest
public class BatchableContactDebuggerTest {
	@TestSetup
    private static void setup() {
    	List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
			contacts.add(new Contact(LastName='Contact' + i));            
        }
        
        insert contacts;
    }
    
    @IsTest
    private static void testExecuteBatch() {
        Test.startTest();
        Id jobId = Database.executeBatch(new BatchableContactDebugger());
        Test.stopTest();
        List<AsyncApexJob> job = [SELECT Id FROM AsyncApexJob WHERE Id=:jobId];
        System.assertEquals(1, job.size());
    }
}