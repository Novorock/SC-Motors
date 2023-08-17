public with sharing class FullyPaidOpportunityStage implements TaskDeferrable, OpportunityStage {
    private Opportunity opportunity;

    public FullyPaidOpportunityStage(Opportunity opportunity) {
        this.opportunity = opportunity;
    }

    public Opportunity get() {
        opportunity.StageName = 'Fully Paid';
        opportunity.PaidAmount__c = opportunity.Amount;
        
        return opportunity;
    }

    public Task defer() {
        List<OpportunityContactRole> junction = [
            SELECT Contact.OwnerId
            FROM OpportunityContactRole
            WHERE Opportunity.Id=:opportunity.Id
        ];

        if (junction.size() < 1) {
            ListException e = new ListException();
            e.setMessage('No related contacts error.');
            throw e;
        }

        Datetime now = System.now();
        Datetime t = Datetime.newInstance(
            now.year(),
            now.month(),
            now.day(),
            10,
            0,
            0
        ).addDays(2);

        return new Task(
            OwnerId=junction.get(0).Contact.OwnerId,
            Priority='High',
            Status='Not started',
            Subject='Delivery of goods',
            ReminderDateTime=t,
            WhatId=opportunity.Id
        );
    }
}