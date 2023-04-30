@IsTest
private class LwcAccountControllerTest {
	@TestSetup
    private static void setup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            accounts.add(
            	new Account(
                	Name='Account' + i
                )
            );
        }
        
        insert accounts;
        
        List<Opportunity> opps = new List<Opportunity>();
        Integer counter = 0;
        for (Account acc : accounts) {
       		for (Integer i = 0; i < 3; i++) {
            	opps.add(
            		new Opportunity(
                		Name='Opportunity' + counter,
                    	CloseDate=Date.today().addDays(10),
                    	AccountId=acc.Id,
                        Amount=10 * (counter + 1),
                        StageName='Prospecting'
                	)
            	);
        	}
            counter++;
        }
        
        insert opps;
        
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
        
		Opportunity opp = new Opportunity(
        	Name='TestTest',
            CloseDate=Date.today().addDays(10),
            AccountId=accounts[3].Id,
            StageName='Prospecting',
			Pricebook2Id=pricebookId				            
        );
        
        insert opp;
        
        List<OpportunityLineItem> items = new List<OpportunityLineItem>();
        
        for (PricebookEntry e : entries) {
            items.add(new OpportunityLineItem(
            	OpportunityId=opp.Id,
                PricebookEntryId=e.Id,
                UnitPrice=50,
                Quantity=1
            ));
        }
        
        insert items;
    }
    
	@IsTest
    private static void testGetPagesTotalAmount() {    	
        System.assertEquals(2, LwcAccountController.getPagesTotalAmount(null, null));
        
        System.assertEquals(1, LwcAccountController.getPagesTotalAmount(null, '30'));
        
        System.assertEquals(1, LwcAccountController.getPagesTotalAmount(null, '0'));
        
        System.assertEquals(2, LwcAccountController.getPagesTotalAmount('Account', null));
        
        System.assertEquals(1, LwcAccountController.getPagesTotalAmount('test_test', null));
    }
    
   	@IsTest
    private static void testGetDataByPage() {        
		String serialized = LwcAccountController.getDataByPage(1, 'acc', null);
    	List<Object> data = (List<Object>) JSON.deserializeUntyped(serialized);
        
        System.assertEquals(10, data.size());
        
       	serialized = LwcAccountController.getDataByPage(1, 'acc', '30');
    	data = (List<Object>) JSON.deserializeUntyped(serialized);
        
        System.assertEquals(1, data.size());
        
        serialized = LwcAccountController.getDataByPage(1, null, null);
    	data = (List<Object>) JSON.deserializeUntyped(serialized);
        
        System.assertEquals(10, data.size());
        
        serialized = LwcAccountController.getDataByPage(1, 'test_test', null);
    	data = (List<Object>) JSON.deserializeUntyped(serialized);
        
        System.assertEquals(0, data.size());
    }
    
    @IsTest
    private static void testGetDataById() {
		Id id = [SELECT Id FROM Account WHERE Name='Account1'].Id;		
        
		String serialized = LwcAccountController.getDataById('b');
    	List<Object> data = (List<Object>) JSON.deserializeUntyped(serialized);
        
        System.assertEquals(0, data.size());
        
        serialized = LwcAccountController.getDataById(id);
    	data = (List<Object>) JSON.deserializeUntyped(serialized);
        
        System.assertEquals(1, data.size());
    }
    
    @IsTest()
    private static void testGetProductsByOppId() {
        Id id = [SELECT Id FROM Opportunity WHERE Name='TestTest'].Id;
        
		String serialized = LwcAccountController.getProductsByOppId(id);
    	List<Object> data = (List<Object>) JSON.deserializeUntyped(serialized);
        
        System.assertEquals(3, data.size());
    }
}