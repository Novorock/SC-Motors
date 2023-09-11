@IsTest
public class BulkPaymentOperationTest {
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
    private static void testPerform() {
		List<Payment__c> payments = new List<Payment__c>();
		payments.addAll(
            new List<Payment__c>{
                new Payment__c(OpportunityName__c='Opportunity0', Amount__c=20),
                new Payment__c(OpportunityName__c='Opportunity1', Amount__c=20),
                new Payment__c(OpportunityName__c='Opportunity0', Amount__c=180)
            }
        );
        
        BulkPaymentOperation operation = new BulkPaymentOperation(payments);
        operation.perform();
        
        Opportunity opportunity0 = [SELECT StageName FROM Opportunity WHERE Name='Opportunity0' LIMIT 1];
        System.assertEquals('Fully Paid', opportunity0.StageName);
        Opportunity opportunity1 = [SELECT StageName FROM Opportunity WHERE Name='Opportunity1' LIMIT 1];
        System.assertEquals('Partially Paid', opportunity1.StageName);
    }
}