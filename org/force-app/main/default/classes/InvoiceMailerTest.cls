@IsTest
private class InvoiceMailerTest {
    @TestSetup
    private static void setup() {
        Opportunity opp = new Opportunity(
            Name='Test Opportunity',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(20)
        );
        
        insert opp;
        
        /*insert new EmailTemplate(
        	Name='Template',
            Body='Body<{!Contact.Name}, {!Opportunity.Name}>'
        );*/
        
        Contact contact = new Contact(
        	FirstName='Test',
            LastName='Contact',
            Email='test.contact@gmail.com'
        );
        
        insert contact;
        
        insert new OpportunityContactRole(
        	OpportunityId=opp.Id,
            ContactId=contact.Id,
            IsPrimary=True
        );
    }
    
    @IsTest
    private static void testGetEmailData() {
   		Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name='Test Opportunity'];
        
        String serialized = InvoiceMailer.getEmailData(opp.Id);
        Map<String, Object> emailData = (Map<String, Object>) JSON.deserializeUntyped(serialized);
        
        System.assert(emailData.containsKey('subject'));
        
        try {
        	String subject = (String) emailData.get('subject');
            System.assertEquals(subject, opp.Invoice_Number__c);
        } catch (Exception e) {
            System.assert(false, 'Invalid subject');
        }
        
        System.assert(emailData.containsKey('recipient'));
        
        System.assert(emailData.containsKey('body'));
    }
    
    @IsTest
    private static void testGetRelatedInvoicePdfId() {
        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name='Test Opportunity'];
        
        try {
            // File was not generated
        	InvoiceMailer.getRelatedInvoicePdfId(opp.Id);
        } catch (Exception e) {
            System.assert(e instanceof InvoiceMailerException, e.getMessage());
        }
        
		ContentVersion file = new ContentVersion();
        file.Title = opp.Invoice_Number__c;
        file.PathOnClient = String.valueOf('TestFile.pdf');
        file.VersionData = Blob.valueOf('sample of text');
        
        insert file;
        
		Id docId = [
        	SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Title=:opp.Invoice_Number__c
        ].ContentDocumentId;
        
        Id actual = InvoiceMailer.getRelatedInvoicePdfId(opp.Id);
        
        System.assertEquals(docId, actual);
    }
    
    @IsTest
    // The invoice pdf was not generated
    private static void testNegativeSendEmail() {
    	Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name='Test Opportunity'];
        Contact primary = [SELECT Id FROM Contact WHERE FirstName='Test' AND LastName='Contact'];
        
        Test.startTest();
        
        try {
            InvoiceMailer.sendEmail('subject', 'body', primary.Id, opp.Id);
            
        } catch (Exception e) {
            System.assert(e instanceof InvoiceMailerException);
            System.assert(Limits.getEmailInvocations() < 1);
        }
        
        Test.stopTest();
    }
    
    @IsTest
    // The invoice pdf was generated
    private static void testPositiveSendEmail() {
        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name='Test Opportunity'];
        Contact primary = [SELECT Id FROM Contact WHERE FirstName='Test' AND LastName='Contact'];
        
        ContentVersion file = new ContentVersion();
        file.Title = 'subject';
        file.PathOnClient = String.valueOf('TestFile.pdf');
        file.VersionData = Blob.valueOf('sample of text');
        insert file;
        
        Test.startTest();
        
        InvoiceMailer.sendEmail('subject', 'body', primary.Id, opp.Id);
        System.assert(Limits.getEmailInvocations() > 0);
        
        Test.stopTest();
    }
}