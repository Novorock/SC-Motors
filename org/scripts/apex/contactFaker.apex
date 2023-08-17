Http client = new Http();

HttpRequest request = new HttpRequest();
request.setEndpoint('https://my.api.mockaroo.com/contacts.json');
request.setHeader('X-API-Key', '188f4900');
request.setMethod('GET');

HttpResponse response = client.send(request);
Integer statusCode = response.getStatusCode();

if (200 <= statusCode && statusCode < 300) {
    List<Contact> contacts = (List<Contact>) JSON.deserializeStrict(response.getBody(), List<Contact>.class);

    for (Contact contact : contacts) {
        contact.Birthdate = Date.today();
        contact.LastName = 'test-' + contact.LastName;
    }

    insert contacts;
}