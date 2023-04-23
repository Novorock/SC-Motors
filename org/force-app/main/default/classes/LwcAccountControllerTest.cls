@IsTest
private class LwcAccountControllerTest {
	@TestSetup
    private static void setup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
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
    }
    
    @IsTest
    private static void testPagesAmountCalc() {
        System.assertEquals(2, LwcAccountController.pagesAmountCalc(20));
        System.assertEquals(3, LwcAccountController.pagesAmountCalc(27));
        System.assertEquals(2, LwcAccountController.pagesAmountCalc(19));
        System.assertEquals(1, LwcAccountController.pagesAmountCalc(0));
    }
    
    @IsTest
    private static void testCustomSerialize() {
		List<Account> container = [
            SELECT Account.Id, Account.Name,
            (
                SELECT
                    Opportunity.Name,
                    Opportunity.CreatedDate,
                    Opportunity.CloseDate,
                    Opportunity.Amount
                FROM Opportunities
            )
            FROM Account
        ];
        
        String serialized = LwcAccountController.customSerialize(container, 0);
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(serialized);
        
        try {
        	List<Object> accounts = (List<Object>) result.get('Accounts');
            
            System.assert(accounts.size() == 3);
            
            for (Object acc : accounts) {
                Map<String, Object> item = (Map<String, Object>) acc; 
                List<Object> opps = (List<Object>) item.get('Opportunities'); 
                System.assert(opps.size() == 3);
            }
        } catch (Exception e) {
            System.assert(false, 'Deserialization error: ' + e.getMessage());
        }
    }
    
	@IsTest
    private static void getAccountOpportunityById() {
		List<Account> container = [
            SELECT Id FROM Account WHERE Name='Account0'
        ];
        
        String serialized = LwcAccountController.getAccountOpportunityById(container[0].Id);
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(serialized);
        
        try {
        	List<Object> accounts = (List<Object>) result.get('Accounts');
            Map<String, Object> item = (Map<String, Object>) accounts.get(0);
            
            System.assertEquals('Account0', (String) item.get('Name'));
        } catch (Exception e) {
            System.assert(false, 'Deserialization error: ' + e.getMessage());
        }
    }
    
   	@IsTest
    private static void testGetAccountOpportunityPage() {        
        try {
            String serialized = LwcAccountController.getAccountOpportunityPage(10);
        	Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(serialized);
            
        	List<Object> accounts = (List<Object>) result.get('Accounts');
            
            System.assert(accounts.size() == 0);
            
            serialized = LwcAccountController.getAccountOpportunityPage(1);
        	result = (Map<String, Object>) JSON.deserializeUntyped(serialized);
            
        	accounts = (List<Object>) result.get('Accounts');
            
            for (Object acc : accounts) {
                Map<String, Object> item = (Map<String, Object>) acc; 
                List<Object> opps = (List<Object>) item.get('Opportunities'); 
                System.assert(opps.size() == 3);
            }
        } catch (Exception e) {
            System.assert(false, 'Deserialization error: ' + e.getMessage());
        }
    }
    
    @IsTest
    private static void testGetAccountOpportunityPageFiltered() {
   		try {
            String serialized = LwcAccountController.getAccountOpportunityPageFiltered(1, 'Acc', 5, 40);
        	Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(serialized);
        	List<Object> accounts = (List<Object>) result.get('Accounts');
            
            System.assert(accounts.size() == 1);
            
            try {
            	serialized = LwcAccountController.getAccountOpportunityPageFiltered(1, '', null, null);
            } catch (Exception e) {
                System.assert(e instanceof AuraHandledException);
            }
            
            serialized = LwcAccountController.getAccountOpportunityPageFiltered(1, 'Acc', -100, -10);
        	result = (Map<String, Object>) JSON.deserializeUntyped(serialized);
        	accounts = (List<Object>) result.get('Accounts');
            
            System.assert(accounts.size() == 3);
            
            serialized = LwcAccountController.getAccountOpportunityPageFiltered(1, '', 5, 70);
        	result = (Map<String, Object>) JSON.deserializeUntyped(serialized);
        	accounts = (List<Object>) result.get('Accounts');
            
            System.assert(accounts.size() == 2);
        } catch (Exception e) {
            System.assert(false, 'Deserialization error: ' + e.getMessage());
        }	
    }
}