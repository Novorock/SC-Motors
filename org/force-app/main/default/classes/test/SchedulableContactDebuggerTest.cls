@IsTest
public class SchedulableContactDebuggerTest {
	@TestSetup
    private static void setup() {
    	List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
			contacts.add(new Contact(LastName='Contact' + i));            
        }
        
        insert contacts;
    }
    
    @IsTest
    private static void testExecute() {
        Test.startTest();
       	Id cronId = System.schedule('Test Job', '0 0 0 * * ? *', new SchedulableContactDebugger());
        Test.stopTest();
        List<CronTrigger> cronTrigger = [SELECT Id FROM CronTrigger WHERE Id=:cronId];
        System.assertEquals(1, cronTrigger.size());
    }
}