@IsTest
public class PaymentOperationTest implements TaskCatchable {    
    @IsTest
    private static void testPerformWith() {
        Opportunity opportunity1 = new Opportunity(Name='Opportunity1', StageName='Prospecting', Amount=200, PaidAmount__c=0, CloseDate=Date.today().addDays(5));
        insert opportunity1;
        Payment__c fullPayment = new Payment__c(OpportunityName__c='Opportunity1', Amount__c=200);
        
        Opportunity opportunity2 = new Opportunity(Name='Opportunity2', StageName='Prospecting', Amount=200, PaidAmount__c=0, CloseDate=Date.today().addDays(5));
        insert opportunity2;
        Payment__c partiallyPayment = new Payment__c(OpportunityName__c='Opportunity2', Amount__c=20);
        
        PaymentOperation fullPaymentOperation = new PaymentOperation(fullPayment, opportunity1);
        Opportunity result = fullPaymentOperation.performWith(new PaymentOperationTest());
        System.assertEquals('Fully Paid', result.StageName);
        
        PaymentOperation partiallyPaymentOperation = new PaymentOperation(partiallyPayment, opportunity2);
        result = partiallyPaymentOperation.performWith(new PaymentOperationTest());
        System.assertEquals('Partially Paid', result.StageName);
    }
    
    public void handle(TaskDeferrable deferrable) {
        System.debug('This is a stub of TaskCatchable');
    } 
}