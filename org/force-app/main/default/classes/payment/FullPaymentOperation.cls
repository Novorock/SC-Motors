public with sharing class FullPaymentOperation implements PaymentOperation {
    void perform(Payment__c payment, OpportunityPaymentAccessObject accessObject) {
        Opportunity opportunity = accessObject.getRelatedOpportunity(payment);
        opportunity.PaidAmount__c = opportunity.Amount;
        opportunity.StageName = 'Fully Paid';
    }
}