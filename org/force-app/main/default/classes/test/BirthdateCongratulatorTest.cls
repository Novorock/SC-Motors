@IsTest
public class BirthdateCongratulatorTest {
	@TestSetup
    private static void setup() {
    	List<Contact> contacts = new List<Contact>();
        
        for (Integer i = 0; i < 10; i++) {
            contacts.add(new Contact(LastName='Contact' + i, Email='random' + i + '.email@gmail.com', Birthdate=Date.today()));
        }
        
        contacts.add(new Contact(LastName='Wron Email', Birthdate=Date.today()));
        insert contacts;
        
        insert new Opportunity(
            Name='Opportunity',
            StageName='Prospecting',
            Amount=200,
            CloseDate=Date.today().addDays(5)
        );
    }
    
    @IsTest
    private static void testExecute() {
        Test.startTest();
        Database.executeBatch(new BirthdateCongratulator());
        Test.stopTest();
        System.assertEquals(10, BirthdateCongratulator.emailInvocations);
    }
}