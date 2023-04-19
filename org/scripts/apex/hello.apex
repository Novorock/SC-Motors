// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

Integer min = 0;
Integer max = 1000;
String searchTokens = 'Hartford';
Integer recordsAmount = 0;

List<AggregateResult> results = [
    SELECT AccountId
    FROM Opportunity
    GROUP BY AccountId
    HAVING SUM(AMOUNT) > :min AND SUM(AMOUNT) < :max
];

List<Id> idsFilteredByTotalPrice = new List<Id>();
for (AggregateResult ar : results) {
    idsFilteredByTotalPrice.add((Id) ar.get('AccountId'));
}

if (String.isNotBlank(searchTokens)) {Ц
    String criteria = searchTokens + '%';
    recordsAmount = Database.countQuery('SELECT COUNT() FROM Account WHERE Name LIKE :criteria AND Id IN :idsFilteredByTotalPrice');
} else {
    recordsAmount = idsFilteredByTotalPrice.size();
}

System.debug(recordsAmount);


String data = OpportunityReportPerAccountController.getAccountOpportunityPage(1);
System.debug(data);

String data = OpportunityReportPerAccountController.getAccountOpportunityPageFiltered(1, 'ha', 0, 500000);
System.debug(data);

String data = OpportunityReportPerAccountController.getAccountOpportunityById('0012w00001Kunf7AAB');
System.debug(data);

List<Contact> recipient = [SELECT Id, Name, Email FROM Contact];
List<Object> data = new List<Object>();
data.add(recipient);
data.add('html body'); 
String s = JSON.serializePretty(data);
System.debug(data);

System.debug(InvoiceMailer.getEmailData('0062w00000KRQe1AAH'));

System.debug(OpportunityReportPerAccountController.getProductsDataByOppId('0062w00000KRQe1AAH'));