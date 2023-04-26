@IsTest
public class InvoicePdfFileControllerTest {
	@IsTest(SeeAllData=True)
    private static void testInitializedProperties() {
        Id pricebookId = [SELECT Id FROM Pricebook2 WHERE Name='Standard Price Book'].Id;
        
		Opportunity opp = new Opportunity(
        	Name='Test Opportunity',
            CloseDate=Date.today().addDays(10),
            StageName='Prospecting',
            Pricebook2Id=pricebookId,
            Amount=100
        );
        
        insert opp;
        
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
       
      	List<Product2> products = [SELECT Id FROM Product2];
       
        if (products.size() < 1) {
            System.assert(false, 'Existance of products is expecting');
        } 
        
        OpportunityLineItem item = new OpportunityLineItem(
        	OpportunityId=opp.Id,
            Product2Id=products[0].Id,
            Quantity=1,
            UnitPrice=50
        );
        
        insert item;
       	
        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        InvoicePdfFileController myController = new InvoicePdfFileController(std);
        
        System.assertEquals(50, myController.Total);
        System.assertEquals(1, myController.products.size());
        
        delete item;
        delete contact;
        delete opp;
    }
}