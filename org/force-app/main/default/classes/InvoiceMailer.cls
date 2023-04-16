public with sharing class InvoiceMailer {
    @AuraEnabled
    public static String getEmailData(String oppId) {
        Opportunity opp = [SELECT Invoice_Number__c FROM Opportunity WHERE Id=:oppId];

        EmailTemplate template = [SELECT Id, Subject, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'Opportunity_Invoice_Attachment'];

        OpportunityContactRole Primary = [SELECT Contact.Id
            FROM OpportunityContactRole
            WHERE IsPrimary=True
            AND OpportunityId=:oppId];

        List<Messaging.RenderEmailTemplateBodyResult> renderedEmail = Messaging.renderEmailTemplate(
            Primary.id, oppId, new List<String> {template.Body});

        Map<String, String> data = new Map<String, String>();
        data.put('subject', String.valueOf(opp.Invoice_Number__C));
        data.put('recipientId', Primary.Contact.Id);
        data.put('body', renderedEmail.get(0).getMergedBody());

        String serialized = JSON.serializePretty(data);

        return serialized;
    }

    @AuraEnabled
    public static void sendEmail(String subject, String body, String recipientId, String relatedToId) {
        List<Messaging.SingleEmailMessage> container = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message.setSubject(subject);
        message.setPlainTextBody(body);
        message.setToAddresses(new List<String> {'prefercink@gmail.com'});
        message.setTargetObjectId(recipientId);
        message.setWhatId(relatedToId);
        container.add(message);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(container);

        if (results[0].success) {
            System.debug('The email was sent successfully');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
}