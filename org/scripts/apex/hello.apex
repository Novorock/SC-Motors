// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

List<Payment__c> payments = new List<Payment__c>{
    new Payment__c(
        OpportunityName__c='Roma',
        Amount__c=100
    ),
    new Payment__c(
        OpportunityName__c='Roma',
        Amount__c=60
    ),
    new Payment__c(
        OpportunityName__c='Pavel',
        Amount__c=150
    )
};

System.debug(new List<Contact>() instanceof Iterable<Contact>);

System.debug(Payment__c.OpportunityName__c.getDescribe().getSObjectField());

SObject obj = [SELECT Name FROM Contact LIMIT 1][0];
System.debug(obj.getSObjectType());

System.debug(obj.getSObjectType().getDescribe().fields.getMap().keySet().contains('name'));

Contact contact = new Contact(LastName='Test');
System.debug(contact.getSObjectType() == Contact.getSObjectType());
