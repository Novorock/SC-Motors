Http client = new Http();

HttpRequest request = new HttpRequest();
request.setHeader('X-API-Key', '188f4900');
request.setEndpoint('https://my.api.mockaroo.com/leads.json');
request.setMethod('GET');

HttpResponse response = client.send(request);

if (response.getStatusCode() == 200) {
    String serialized = response.getBody();

    List<Lead> records = new List<Lead>();
    List<Object> leads = (List<Object>) JSON.deserializeUntyped(serialized);

    List<Product2> products = [SELECT ProductCode FROM Product2];

    for (Object untyped : leads) {
        Map<String, Object> lead = (Map<String, Object>) untyped;
    
        Integer i = (Integer) (Math.random() * (products.size() - 1)); 

        records.add(new Lead(
            FirstName=(String) lead.get('first_name'),
            LastName=(String) lead.get('last_name'),
            Company=(String) lead.get('company'),
            Phone=(String) lead.get('phone'),
            Email=(String) lead.get('email'),
            Product__c=products[i].ProductCode
        ));
    }

    for (Lead lead : records) {
        System.debug(lead);
    }

    insert records;
} else {
    System.debug(response.getStatus());
}
