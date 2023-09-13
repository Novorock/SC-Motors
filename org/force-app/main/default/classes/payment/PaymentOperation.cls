public with sharing class PaymentOperation {
    private Payment__c payment;
    private Opportunity opportunity;
    
    public PaymentOperation(Payment__c payment, GetByNameRepository repository) {
        this.payment = payment;
        List<Opportunity> opportunities = (List<Opportunity>) repository.getByName(payment.OpportunityName__c);

        if (opportunities.size() > 1) {
            IllegalArgumentException illegal = new IllegalArgumentException();
            illegal.setMessage('Illegal payment: Multiple opportunities with name "' + payment.OpportunityName__c + '" were met.');
            throw illegal;
        }

        opportunity = opportunities.get(0);
    }

    public void performWith(IUnitOfWork uow) {
        if (payment.Amount__c + opportunity.PaidAmount__c < opportunity.Amount) {
            opportunity.PaidAmount__c += payment.Amount__c;
            opportunity.StageName = 'Partially Paid';
            uow.registerOfModified(opportunity);
        } else if (payment.Amount__c + opportunity.PaidAmount__c >= opportunity.Amount) {
            opportunity.PaidAmount__c = opportunity.Amount;
            opportunity.StageName = 'Fully Paid';

            uow.registerOfModified(opportunity);

            List<OpportunityContactRole> junction = [
                SELECT Contact.OwnerId
                FROM OpportunityContactRole
                WHERE Opportunity.Id=:opportunity.Id
            ];
    
            Datetime now = System.now();
            Datetime t = Datetime.newInstance(
                now.year(),
                now.month(),
                now.day(),
                10,
                0,
                0
            ).addDays(2);
    
            Task task = new Task(
                OwnerId=junction.get(0).Contact.OwnerId,
                Priority='High',
                Status='Not started',
                Subject='Delivery of goods',
                ReminderDateTime=t,
                WhatId=opportunity.Id
            );
            
            uow.registerOfNew(task);
        } else {
            /*IllegalArgumentException e = new IllegalArgumentException();
            e.setMessage('Illegal payment amount. Expected: ' + (opportunity.Amount - opportunity.PaidAmount__c) +
                         + '; Actual: ' + payment.Amount__c + ';'
            );

            throw e;*/
        }
    }
}