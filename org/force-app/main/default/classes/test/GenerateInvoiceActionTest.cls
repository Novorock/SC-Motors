@IsTest
public class GenerateInvoiceActionTest {
    @TestSetup
    private static void setup() {         
		Account account = new Account(
        	Name='Account'
        );
        
        insert account;
        
        Opportunity opportunity = new Opportunity(
        	Name='Opportunity',
            CloseDate=Date.today().addDays(10),
            AccountId=account.Id,
            StageName='Prospecting'
        );
        
        insert opportunity;
        
        Id pricebookId = Test.getStandardPricebookId();
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 3; i++) {
            products.add(
            	new Product2(
                	ProductCode='PR' + i,
                    Name='TestProduct' + i
                )
            );
        }
        
        insert products;
        
		List<PricebookEntry> entries = new List<PricebookEntry>();
		for (Product2 p : products) {
    		entries.add(
    			new PricebookEntry(
					Product2Id=p.Id,
            		Pricebook2Id=pricebookId,
            		UnitPrice=50,
            		isActive=True
        		)
    		);
 		}		
	
		insert entries;        
       	
        List<OpportunityLineItem> items = new List<OpportunityLineItem>();
        for (PricebookEntry entry : entries) {
            items.add(new OpportunityLineItem(
            	OpportunityId=opportunity.Id,
                PricebookEntryId=entry.Id,
                UnitPrice=50,
                Quantity=1
            ));
        }
        
        insert items;    
    }
    
	@IsTest
    private static void testGenerateInvoice() {
        Test.startTest();
        Opportunity opp = [SELECT Id, Invoice_Number__c FROM Opportunity WHERE Name='Opportunity' LIMIT 1];
        System.debug(opp);
        GenerateInvoiceAction.generateInvoicePdf(opp.Id); 
        
      	ContentDocument doc = [
            SELECT Id
            FROM ContentDocument
            WHERE Title=:opp.Invoice_Number__c
            LIMIT 1
        ]; 

        List<ContentDocumentLink> links = [
        	SELECT Id
           	FROM ContentDocumentLink
            WHERE LinkedEntityId=:opp.Id
            AND ContentDocumentId=:doc.Id
        ];
        
    	System.assert(links.size() > 0);
        
        GenerateInvoiceAction.generateInvoicePdf(opp.Id);
        
		List<ContentVersion> versions = [
        	SELECT Id
           	FROM ContentVersion
            WHERE ContentDocumentId=:doc.Id
        ];
        System.assertEquals(2, versions.size());
        Test.stopTest();
    }
}