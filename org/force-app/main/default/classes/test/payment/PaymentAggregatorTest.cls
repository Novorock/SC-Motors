@IsTest
public class PaymentAggregatorTest {
    @IsTest
    private static void testAggregator() {
        List<Payment__c> payments = new List<Payment__c>();
		payments.addAll(
            new List<Payment__c>{
                new Payment__c(OpportunityName__c='Opportunity1', Amount__c=20),
                new Payment__c(OpportunityName__c='Opportunity2', Amount__c=20),
                new Payment__c(OpportunityName__c='Opportunity1', Amount__c=20)
            }
        );
        
        PaymentAggregator aggregator = new PaymentAggregator(payments);
        List<Payment__c> aggregated = new List<Payment__c>();
		Iterator<Payment__c> iterator = aggregator.iterator();
        
        Integer size = 0;
        while (iterator.hasNext()) {
            size++;
            iterator.next();
        }
        
        System.assertEquals(2, size);
        
        try {
            iterator.next();
            System.assert(false, 'No element expected');
        } catch(NoSuchElementException e) {
        }
    }
}