public with sharing class BulkPaymentOperation implements TaskCatchable {
    private PaymentAggregator aggregator;
    private OpportunityPaymentAccessObject accessObject;
    private List<Task> tasks;

    public BulkPaymentOperation(List<Payment__c> payments) {
        aggregator = new PaymentAggregator(payments);
        accessObject = new OpportunityPaymentAccessObject(payments);
        tasks = new List<Task>();
    }

    public void perform() {
        CustomPaymentIterator iterator = aggregator.iterator();
        List<Opportunity> opportunities = new List<Opportunity>();

        while (iterator.hasNext()) {
            Payment__c payment = iterator.next();
            System.debug(payment);
            Opportunity opportunity = accessObject.getRelatedOpportunity(payment);
            PaymentOperation operation = new PaymentOperation(payment, opportunity);
            Opportunity opp = operation.performWith(this);
            System.debug(opp);
            opportunities.add(opp);
        }

        update opportunities;
        insert tasks;
    }

    public void handle(TaskDeferrable defferable) {
        Task task = defferable.defer();
        
        if (task != null) {
            tasks.add(task);
        }
    }
}