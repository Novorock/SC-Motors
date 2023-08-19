public class GenerateInvoiceAction {
    @AuraEnabled
    public static void generateInvoicePdf(String oppId) {
        Opportunity opp = [
            SELECT Invoice_Number__c
            FROM Opportunity
            WHERE Id=:oppId
        ];

        PageReference invoicePdf = Page.InvoicePdfFile;
        invoicePdf.getParameters().put('id', oppId);
        Blob binary;
        
        if (Test.isRunningTest()) {
			binary = Blob.valueOf('Content version');        	    
        } else {
            try {
            	binary = invoicePdf.getContent();
        	} catch (VisualforceException e) {
            	System.debug(logginglevel.ERROR, e.getMessage());
        	}
        }

        ContentVersion version = new ContentVersion();
        version.Title = String.valueOf(opp.Invoice_Number__c);
        version.PathOnClient = String.valueOf(opp.Invoice_Number__c + '.pdf');
        version.VersionData = binary;
        version.IsMajorVersion = true; 
        
        List<ContentDocument> documents = [
            SELECT Id
            FROM ContentDocument
            WHERE Title=:opp.Invoice_Number__c
        ];

        if (documents.size() > 0) {
            ContentDocument document = documents.get(0);
            version.ContentDocumentId = document.Id;

            insert version;
        } else {
            insert version;
            
            Id docId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id=:version.Id
            ].ContentDocumentId;

            ContentDocumentLink link = new ContentDocumentLink();
            link.ContentDocumentId = docId;
            link.Visibility = 'AllUsers';
            link.ShareType = 'v';
            link.LinkedEntityId = oppId;

            insert link;
        }
    }
}