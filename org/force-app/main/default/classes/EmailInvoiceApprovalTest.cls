@IsTest
private class EmailInvoiceApprovalTest {
    @TestSetup
    static void setup() {
        Opportunity test1 = new Opportunity(
            Name='Test1 Opportunity',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(20)
        );

        Opportunity test2 = new Opportunity(
            Name='Test2 Opportunity',
            StageName='Prospecting',
            CloseDate=Date.today().addDays(20)
        );

        insert new List<Opportunity>{test1, test2};
    }

    @isTest
    static void runPositiveHandleTest() {
        EmailInvoiceApproval approval = new EmailInvoiceApproval();

        Opportunity test1 = [
            SELECT Name, StageName, Invoice_Number__c
            FROM Opportunity
            WHERE Name='Test1 Opportunity'
        ];

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        email.subject = test1.Invoice_Number__c;
        email.plainTextBody = 'Hello! I received the invoice and Approved the opportunity.';
        env.fromAddress = 'test@user1.com';

        Messaging.InboundEmailResult result = approval.handleInboundEmail(email, env);

        System.assert(result.success);

        test1 = [
            SELECT StageName FROM Opportunity WHERE Name='Test1 Opportunity'
        ];

        System.assertEquals('Qualification', test1.StageName);

        Opportunity test2 = [
            SELECT Name, StageName, Invoice_Number__c
            FROM Opportunity
            WHERE Name='Test2 Opportunity'
        ];

        email.subject = test2.Invoice_Number__c;
        email.plainTextBody = 'Hello! I received the invoice and Rejected the opportunity.';
        env.fromAddress = 'test@user2.com';

        result = approval.handleInboundEmail(email, env);

        System.assert(result.success);

        test2 = [
            SELECT StageName FROM Opportunity WHERE Name='Test2 Opportunity'
        ];

        System.assertEquals('Closed Lost', test2.StageName);
    }
}