public with sharing class InvoicePdfFileController {
    public OpportunityContactRole Primary {set; get;}
    public List<OpportunityLineItem> products {set; get;}
    public Double Total {set; get;}
    
    public InvoicePdfFileController(ApexPages.StandardController controller) {
        String opportunityId = controller.getId();
        Primary = [SELECT Contact.Name, Contact.Phone, Contact.Email
                          FROM OpportunityContactRole
                          WHERE IsPrimary=True
                          AND OpportunityId=:opportunityId];
        
        products = [SELECT Product2.Name, Quantity, UnitPrice, TotalPrice
                                   FROM OpportunityLineItem
                                   WHERE OpportunityId=:opportunityId];
        AggregateResult[] result = [SELECT SUM(TotalPrice)
                 FROM OpportunityLineItem
                 WHERE OpportunityId=:opportunityId
                 GROUP BY OpportunityId];
        
        Total = (Double) result[0].get('expr0');
    }
}