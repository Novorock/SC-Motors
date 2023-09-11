@IsTest
public class PartiallyPaidOpportunityStageTest {
    @TestSetup
    private static void setup() {
		Opportunity opportunity = new Opportunity(
            Name='Opportunity',
            StageName='Prospecting',
            Amount=200,
            CloseDate=Date.today().addDays(5)
        );
        insert opportunity;
    }
    
    @IsTest
    private static void testGet() {
        Opportunity opportunity = [SELECT Name, StageName, PaidAmount__c, Amount FROM Opportunity WHERE Name='Opportunity'];
    	PartiallyPaidOpportunityStage stage = new PartiallyPaidOpportunityStage(opportunity, 50.3);
        opportunity = stage.get();
        
        System.assertEquals('Partially Paid', opportunity.StageName);
        System.assertEquals(50.3, opportunity.PaidAmount__c);
    }
}