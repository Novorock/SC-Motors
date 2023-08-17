public with sharing class CustomPaymentIterator implements Iterator<Payment__c> {
    private Integer i;
    private List<String> opportunityNames;
    private Map<String, Payment__c> payments;
    
    public CustomPaymentIterator(List<String> opportunityNames, Map<String, Payment__c> payments) {
        i = 0;
        this.opportunityNames = opportunityNames;
        this.payments = payments;
    }

    public Boolean hasNext() {
        return i < opportunityNames.size();
    }

    public Payment__c next() {
        if (hasNext()) {
            String opporunityName = opportunityNames.get(i);
            Payment__c next = payments.get(opporunityName);
            i += 1;

            return next;
        } else {
            throw new NoSuchElementException('Iterator has no more elements.');
        }
    }
}