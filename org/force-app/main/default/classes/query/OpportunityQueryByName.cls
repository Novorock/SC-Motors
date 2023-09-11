public with sharing class OpportunityQueryByName implements IQuery {
    private Set<String> keys;
    
    public OpportunityQueryByName(Set<String> keys) {
        this.keys = keys;
    }

    public List<Opportunity> execute() {
        return [SELECT Name, Amount, PaidAmount__c, StageName
                FROM Opportunity WHERE Name IN :keys];
    }

    public SObjectType getSObjectType() {
        return Opportunity.getSObjectType();
    }
}