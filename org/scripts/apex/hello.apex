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

String subject = 'INV-005030sdfaf';
Pattern InvoiceSubjectPattern = Pattern.compile('INV-\\d{6}');
Matcher SubjectMatcher = InvoiceSubjectPattern.matcher(subject);
System.debug(SubjectMatcher.matches());

List<String> tokens = new List<String> {'token1', 'token2', 'token3'};
System.debug(String.join(tokens, ', '));

// Test Query Builder

QueryBuilder builder = new QueryBuilder();
// builder.setTotalPriceFilter('200');
builder.setPage(2);
List<AggregateResult> results = (List<AggregateResult>) builder.execute();

for (AggregateResult result : results) {
    System.debug(result.get('AccountId') + ' ' + result.get('Total') + result.get('AccountName'));
}

System.debug(LwcAccountController.getPagesTotalAmount(null, null));

System.debug(LwcAccountController.getPagesTotalAmount('fadfa', null));

System.debug(LwcAccountController.getDataByPage(1, 'e', null));

System.debug(LwcAccountController.getDataById('0012w00001Kunf8AAB'));

System.debug(LwcAccountController.getProductsByOppId('0062w00000Lp6OVAAZ'));

