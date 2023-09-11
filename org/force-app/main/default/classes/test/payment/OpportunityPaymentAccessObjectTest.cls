@IsTest
public class OpportunityPaymentAccessObjectTest {
    @TestSetup
    private static void setup() {
    	List<Opportunity> opportunities = new List<Opportunity>();
        
        String stage = 'Prospecting';
        Date closeDate = Date.today().addDays(5);
        opportunities.addAll(
            new List<Opportunity>{
                new Opportunity(Name='Opportunity1', StageName=stage, Amount=200, CloseDate=closeDate),
                new Opportunity(Name='Opportunity2', StageName=stage, Amount=200, CloseDate=closeDate),
                new Opportunity(Name='Opportunity2', StageName=stage, Amount=200, CloseDate=closeDate)
            }
        );
        
        insert opportunities;
    }
    
    @IsTest
    private static void testGetRelatedOpportunity() {
        List<Payment__c> payments = new List<Payment__c>();
		payments.addAll(
            new List<Payment__c>{
                new Payment__c(OpportunityName__c='Opportunity1', Amount__c=20),
                new Payment__c(OpportunityName__c='Opportunity2', Amount__c=20),
                new Payment__c(OpportunityName__c='Unexisted', Amount__c=20)
            }
        );
	        
    	OpportunityPaymentAccessObject accessObject = new OpportunityPaymentAccessObject(payments);
		Opportunity opportunity = accessObject.getRelatedOpportunity(payments[0]);
        System.assertNotEquals(null, opportunity);
        
        try {
            accessObject.getRelatedOpportunity(payments[1]);
        	System.assert(false, 'Expected multiple opportunity error');    
        } catch(Exception e) {
		}
        
        try {
            accessObject.getRelatedOpportunity(payments[2]);
        	System.assert(false, 'Expected no opportunity error');    
        } catch(Exception e) {
		} 
    }
}