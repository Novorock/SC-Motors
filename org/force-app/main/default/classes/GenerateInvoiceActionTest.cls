@IsTest
public class GenerateInvoiceActionTest {    
	@IsTest(SeeAllData=true)
    // !!! The test expected existance of opportunities
    private static void testGenerateInvoice() {
        Id oppId = [SELECT OpportunityId FROM OpportunityLineItem][0].OpportunityId; 
		Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Id=:oppId];
        
        Test.startTest();
        
        GenerateInvoiceAction.generateInvoicePdf(opp.Id); 
        
        try {
        	Id docId = [
            	SELECT Id
            	FROM ContentDocument
            	WHERE Title=:opp.Invoice_Number__c
        	].Id;
            
            List<ContentDocumentLink> links = [
            	SELECT Id
            	FROM ContentDocumentLink
            	WHERE LinkedEntityId=:opp.Id
            	AND ContentDocumentId=:docId
        	];
        
     		System.assert(links.size() > 0);   
        } catch (Exception e) {
       		System.assert(false, 'The file was not generated: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
}