public with sharing class InvoiceMailer {
    @AuraEnabled
    public static String getEmailData(String oppId) {
        Opportunity opp = [
            SELECT Invoice_Number__c
            FROM Opportunity
            WHERE Id=:oppId
        ];

        EmailTemplate template = [
            SELECT Id, Subject, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'Opportunity_Invoice_Attachment'
        ];

        OpportunityContactRole Primary = [
            SELECT Contact.Id
            FROM OpportunityContactRole
            WHERE IsPrimary=True
            AND OpportunityId=:oppId
        ];

        Contact recipient = [
            SELECT Id, Name, Email
            FROM Contact
            WHERE Id=:Primary.Contact.Id
        ];

        Messaging.RenderEmailTemplateBodyResult renderedEmail =
            Messaging.renderEmailTemplate(Primary.Contact.Id, oppId, new List<String> {template.Body}).get(0);

        String emailData = JSON.serialize(new Map<String, Object> {
            'subject' => opp.Invoice_Number__c, 'recipient' => recipient, 'body' => renderedEmail.getMergedBody()
        });

        return emailData;
    }

    @AuraEnabled
    public static String getRelatedInvoicePdfId(String oppId) {
        Opportunity opp = [
            SELECT Invoice_Number__c
            FROM Opportunity
            WHERE Id=:oppId
        ];

        List<ContentDocument> container = [
            SELECT Id
            FROM ContentDocument
            WHERE Title=:opp.Invoice_Number__c
        ];

        if (container.size() < 1) {
            throw new InvoiceMailerException('The invoice was not generated.');
        } else {
            return String.valueOf(container.get(0).Id);
        }
    }

    @AuraEnabled
    public static void sendEmail(String subject, String body, String recipientId, String relatedToId) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        EmailServicesFunction emailFunction = [
            SELECT Id
            FROM EmailServicesFunction
            WHERE FunctionName='Email Invoice Approval Service'
       	];
        
        List<EmailServicesAddress> eServiceAddrs = [
            SELECT Id, LocalPart, EmailDomainName
            FROM EmailServicesAddress
            WHERE FunctionId=:emailFunction.Id
        ];
        
        String replyAddr = 
            eServiceAddrs.get(0).LocalPart +
            '@' +
            eServiceAddrs.get(0).EmailDomainName;
        
        message.setTargetObjectId(recipientId);
        message.setWhatId(relatedToId);
        message.setSenderDisplayName('Success Motors Support');
       	message.setReplyTo(replyAddr);
        message.setSubject(subject);
        message.setHtmlBody(body);
            
        List<ContentDocument> container = [
            SELECT Id
            FROM ContentDocument
            WHERE Title=:subject
        ];

        if (container.size() < 1) {
            throw new InvoiceMailerException('Can not attach file. The invoice was not generated.');
        }

        ContentVersion file = [
            SELECT VersionData, FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId=:container.get(0).Id
            AND IsLatest=true
        ];

        Blob binary = file.VersionData;
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setBody(binary);
        attachment.setFileName(subject + '.' + file.FileExtension);
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
        
        if (results[0].success) {
            System.debug('The email was sent successfully');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
}