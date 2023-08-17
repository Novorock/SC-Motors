@IsTest
public class FullyPaidOpportunityStageTest {
    @TestSetup
    private static void setup() {
		Opportunity opportunity = new Opportunity(
            Name='Opportunity',
            StageName='Prospecting',
            Amount=200,
            CloseDate=Date.today().addDays(5)
        );
        insert opportunity;
        
        Contact contact = new Contact(LastName='Contact');
        insert contact;
        
        OpportunityContactRole junction = new OpportunityContactRole(OpportunityId=opportunity.Id, ContactId=contact.Id); 
       	insert junction;
    }
    
    @IsTest
    private static void testGet() {
        Opportunity opportunity = [SELECT Name, StageName, PaidAmount__c, Amount FROM Opportunity WHERE Name='Opportunity'];
    	FullyPaidOpportunityStage stage = new FullyPaidOpportunityStage(opportunity);
        opportunity = stage.get();
        
        System.assertEquals('Fully Paid', opportunity.StageName);
        System.assertEquals(opportunity.Amount, opportunity.PaidAmount__c);
    }
    
    @IsTest
    private static void testDefer() {
		Opportunity opportunity = [SELECT Name, StageName, PaidAmount__c, Amount FROM Opportunity WHERE Name='Opportunity'];
        Contact contact = [SELECT OwnerId FROM Contact WHERE Name='Contact'];
        FullyPaidOpportunityStage stage = new FullyPaidOpportunityStage(opportunity);
        Task task = stage.defer();
        System.assertEquals(task.OwnerId, contact.OwnerId);
        
		opportunity = new Opportunity(
            Name='Test',
            StageName='Prospecting',
            Amount=200,
            CloseDate=Date.today().addDays(5)
        );
        insert opportunity;
		stage = new FullyPaidOpportunityStage(opportunity);
        try {
       		stage.defer();
            System.assert(false, 'Expected no related contact error.');
        } catch(Exception e) {
        }
    }
}