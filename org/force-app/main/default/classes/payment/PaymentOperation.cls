public with sharing class PaymentOperation {
    private Payment__c payment;
    private Opportunity opportunity;

    public PaymentOperation(Payment__c payment, Opportunity opportunity) {
        this.payment = payment;
        this.opportunity = opportunity;
    }

    public Opportunity performWith(TaskCatchable catchable) {
        OpportunityStage stage;

        if (payment.Amount__c + opportunity.PaidAmount__c < opportunity.Amount) {
            stage = new PartiallyPaidOpportunityStage(opportunity, payment.Amount__c);
        } else if (payment.Amount__c + opportunity.PaidAmount__c >= opportunity.Amount) {
            stage = new FullyPaidOpportunityStage(opportunity);
            catchable.handle(((TaskDeferrable) stage));
        } else {
            /*IllegalArgumentException e = new IllegalArgumentException();
            e.setMessage('Illegal payment amount. Expected: ' + (opportunity.Amount - opportunity.PaidAmount__c) +
                         + '; Actual: ' + payment.Amount__c + ';'
            );

            throw e;*/
        }

        return stage.get();
    }
}