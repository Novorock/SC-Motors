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

        Contact recipient = [SELECT Id, Name, Email FROM Contact WHERE Id=:Primary.Contact.Id];

        List<Messaging.RenderEmailTemplateBodyResult> renderedEmail = Messaging.renderEmailTemplate(
            Primary.Contact.Id, oppId, new List<String> {template.Body});

        Map<String, Object> data = new Map<String, Object> {
            'subject' => opp.Invoice_Number__C,
            'recipient' => new Map<String, String> {
                'id' => String.valueOf(recipient.Id),
                'name' => recipient.Name,
                'email' => recipient.Email
            },
            'body' => renderedEmail.get(0).getMergedBody()
        };

        String serialized = JSON.serialize(data);
        return serialized;
    }

    @AuraEnabled
    public static String getRelatedInvoicePdfId(String oppId) {
        Opportunity opp = [SELECT Invoice_Number__c FROM Opportunity WHERE Id=:oppId];
        List<ContentDocument> container = [SELECT Id FROM ContentDocument WHERE Title=:opp.Invoice_Number__c];

        if (container.size() < 1) {
            return '';
        } else {
            List<ContentDocumentLink> file = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId=:container.get(0).Id];
            
            return String.valueOf(file.get(0).Id);
        }
    }

    @AuraEnabled
    public static void sendEmail(String subject, String body, String recipientId, String relatedToId) {
        List<Messaging.SingleEmailMessage> container = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message.setSubject(subject);
        message.setHtmlBody(body);
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