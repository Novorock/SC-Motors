public with sharing class PartiallyPaidOpportunityStage implements OpportunityStage {    
    private Opportunity opportunity;
    private Decimal paidAmount;

    public PartiallyPaidOpportunityStage(Opportunity opportunity, Decimal paidAmount) {
        this.opportunity = opportunity;
        this.paidAmount = paidAmount;
    }

    public Opportunity get() {
        opportunity.PaidAmount__c += paidAmount;
        opportunity.StageName = 'Partially Paid';
        
        return opportunity;
    }
}