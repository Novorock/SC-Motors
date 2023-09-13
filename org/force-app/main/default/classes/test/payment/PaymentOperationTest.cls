@IsTest
public class PaymentOperationTest {    
    @TestSetup
    private static void setup() {
    	List<Opportunity> opportunities = new List<Opportunity>();
        
        for (Integer i = 0; i < 3; i++) {
        	opportunities.add(new Opportunity(
                Name='Opportunity' + i,
                StageName='Prospecting',
                Amount=100,
                CloseDate=Date.today().addDays(5)
            ));  
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
    private static void testPerformWith() {
        PublishingUnitOfWork uow = new PublishingUnitOfWork();
        UnitOfWorkSubscribableRepository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
        repository.fetch(new OpportunityQueryByName(new Set<String> {'Opportunity0', 'Opportunity1', 'Opportunity2'}));

        List<Payment__c> payments = new List<Payment__c> {
            new Payment__c(
                OpportunityName__c='Opportunity0',
                Amount__c=53.7
            ),
            new Payment__c(
                OpportunityName__c='Opportunity0',
                Amount__c=46.3
            ),
            new Payment__c(
                OpportunityName__c='Opportunity1',
                Amount__c=100
            ),
            new Payment__c(
                OpportunityName__c='Opportunity2',
                Amount__c=53.5
            )
        };

        for (Payment__c payment : payments) {
            new PaymentOperation(payment, repository).performWith(uow);
        }

        uow.commitWork();

        System.assertEquals('Fully Paid', [SELECT StageName FROM Opportunity WHERE Name='Opportunity0' LIMIT 1].StageName);
        System.assertEquals('Fully Paid', [SELECT StageName FROM Opportunity WHERE Name='Opportunity1' LIMIT 1].StageName);
        System.assertEquals('Partially Paid', [SELECT StageName FROM Opportunity WHERE Name='Opportunity2' LIMIT 1].StageName);
    }
}