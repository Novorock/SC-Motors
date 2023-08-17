public with sharing class PaymentAggregator implements Iterable<Payment__c> {
    private List<String> opportunityNames;
    private Map<String, Payment__c> payments;

    public PaymentAggregator(List<Payment__c> payments) {
        this.payments = new Map<String, Payment__c>();
        opportunityNames = new List<String>();

        for (Payment__c payment : payments) {
            String opportunityName = payment.OpportunityName__c;

            if (this.payments.containsKey(opportunityName)) {
                this.payments.get(opportunityName).Amount__c += payment.Amount__c;
            } else {
                this.payments.put(opportunityName, new Payment__c(
                    OpportunityName__c=opportunityName,
                    Amount__c=payment.Amount__c
                ));
                opportunityNames.add(opportunityName);
            }
        }
    }

    public CustomPaymentIterator iterator() {
        return new CustomPaymentIterator(opportunityNames, payments);
    }
}