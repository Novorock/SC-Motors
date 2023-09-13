@IsTest
public class OnNewPaymentTriggerTest {
    @TestSetup
    private static void setup() {
    	List<Opportunity> opportunities = new List<Opportunity>();
        
        String stage = 'Prospecting';
        Date closeDate = Date.today().addDays(5);
        
        for (Integer i = 0; i < 3; i++) {
        	opportunities.add(new Opportunity(Name='Opportunity' + i, StageName=stage, Amount=200, CloseDate=closeDate));  
        }
        
        insert opportunities;
        
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < opportunities.size(); i++) {
        	contacts.add(new Contact(LastName='Contact' + i));    
        }
        
        insert contacts;
        
        List<OpportunityContactRole> junctions = new List<OpportunityContactRole>();
        for (Integer i = 0; i < contacts.size(); i++) {
        	junctions.add(new OpportunityContactRole(OpportunityId=opportunities.get(i).Id, ContactId=contacts.get(i).Id));
        }
        
		insert junctions;
    }
    
	@IsTest
    private static void testOnNewPaymentTrigger() {
   		List<Payment__c> payments = new List<Payment__c>();

		payments.addAll(
            new List<Payment__c>{
                new Payment__c(OpportunityName__c='Opportunity0', Amount__c=20),
                new Payment__c(OpportunityName__c='Opportunity1', Amount__c=20),
                new Payment__c(OpportunityName__c='Opportunity0', Amount__c=180)
            }
        );  
        
        insert payments;
        
        System.assertEquals('Fully Paid', [SELECT StageName FROM Opportunity WHERE Name='Opportunity0' LIMIT 1].StageName);
        System.assertEquals(1, [SELECT COUNT() FROM Task WHERE Subject='Delivery of goods']);
        System.assertEquals('Partially Paid', [SELECT StageName FROM Opportunity WHERE Name='Opportunity1' LIMIT 1].StageName);
    }
}