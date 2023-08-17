Http client = new Http();

HttpRequest request = new HttpRequest();
request.setHeader('X-API-Key', '188f4900');
request.setEndpoint('https://my.api.mockaroo.com/leads.json');
request.setMethod('GET');

HttpResponse response = client.send(request);

if (response.getStatusCode() == 200) {
    List<Lead> leads = (List<Lead>) JSON.deserialize(response.getBody(), List<Lead>.class);
    List<Product2> products = [SELECT ProductCode FROM Product2];

    for (Lead lead : leads) {
        Integer i = (Integer) (Math.random() * (products.size() - 1));
        lead.Product__c = products[i].ProductCode;
        System.debug(lead);
    }

    insert leads;
} else {
    System.debug(response.getStatus());
}

List<Lead> unreadLeads = [SELECT Id FROM Lead WHERE CreatedDate = TODAY AND IsConverted=false];
List<Database.LeadConvert> converts = new List<Database.LeadConvert>();
LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
for (Lead lead : unreadLeads) {
    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(lead.Id);
    lc.setConvertedStatus(convertStatus.MasterLabel);
    converts.add(lc);
}
Database.convertLead(converts, true);

