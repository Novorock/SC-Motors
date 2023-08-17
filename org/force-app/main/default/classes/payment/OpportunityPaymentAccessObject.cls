public with sharing class OpportunityPaymentAccessObject {
    private Map<String, List<Opportunity>> opportunities;

    public OpportunityPaymentAccessObject(List<Payment__c> payments) {
        Set<String> opportunityNames = new Set<String>();
        opportunities = new Map<String, List<Opportunity>>();
        
        for (Payment__c payment : payments) {
            opportunityNames.add(payment.OpportunityName__c);
        }

        for (Opportunity opportunity : [SELECT Name, Amount, PaidAmount__c, StageName
                                        FROM Opportunity WHERE Name IN :opportunityNames]) {
            String opportunityName = opportunity.Name;
            if (opportunities.containsKey(opportunityName)) {
                opportunities.get(opportunityName).add(opportunity);
            } else {
                opportunities.put(opportunityName, new List<Opportunity>{opportunity});
            }
        }
    }

    public Opportunity getRelatedOpportunity(Payment__c payment) {
        List<Opportunity> opportunities = this.opportunities.get(payment.OpportunityName__c);
        IllegalArgumentException e;
		
        if (opportunities == null) {
        	e = new IllegalArgumentException();
            e.setMessage('No opportunity error.');
            throw e;
        } else if (opportunities.size() > 1) {
            e = new IllegalArgumentException();
            e.setMessage('Multiple opportunities error.');
            throw e;
        } else {
            return opportunities.get(0);
        }
    }
}