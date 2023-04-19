public with sharing class OpportunityReportPerAccountController {
    public static String customSerialize(List<Account> accounts) {
        List<Map<String, Object>> batch = new List<Map<String, Object>>(); 
    
        for (Account acc : accounts) {
            List<Map<String, Object>> oppData = new List<Map<String, Object>>();
            Decimal total = 0;
        
            for (Opportunity opp : acc.Opportunities) {
                total += opp.Amount;

                oppData.add(
                    new Map<String, Object> {
                        'id' => opp.Id,
                        'name' => opp.Name,
                        'createdDate' => opp.CreatedDate,
                        'closeDate' => opp.CloseDate,
                        'amount' => opp.Amount
                    }
                );
            }

            batch.add(
                new Map<String, Object>{
                    'id' => acc.Id,
                    'account' => acc.Name,
                    'total' => total,
                    'opportunities' => oppData
                }
            );
        }

        return JSON.serializePretty(batch);
    }

    @AuraEnabled
    public static Integer getPagesAmount(Integer batchSize) {
        Integer recordsAmount = Database.countQuery('SELECT COUNT() FROM Account'); 
        
        if (Math.mod(recordsAmount, 10) == 0) {
            return recordsAmount / 10;
        } else {
            return (Integer) Math.floor(recordsAmount / 10) + 1;
        }
    }

    @AuraEnabled
    public static String getAccountOpportunityPage(Integer pageN, Integer batchSize) {
        Integer offset = batchSize * (pageN - 1);

        List<Account> accounts = [
            SELECT Account.Id, Account.Name,
            (SELECT Opportunity.Name, Opportunity.CreatedDate, Opportunity.CloseDate, Opportunity.Amount
                FROM Opportunities)
            FROM Account
            WHERE Account.Id IN (SELECT AccountId FROM Opportunity)
            LIMIT :batchSize OFFSET :offset];
        
        return customSerialize(accounts);
    }

    @AuraEnabled
    public static String getAccountOpportunityPageFilter(Integer pageN, Integer batchSize, String criteria) {
        String pattern = criteria + '%';
        Integer offset = batchSize * (pageN - 1);

        List<Account> accounts = [
            SELECT Account.Id, Account.Name,
            (SELECT Opportunity.Name, Opportunity.CreatedDate, Opportunity.CloseDate, Opportunity.Amount
                FROM Opportunities)
            FROM Account
            WHERE Account.Id IN (SELECT AccountId FROM Opportunity) AND Account.Name LIKE :pattern
            LIMIT :batchSize OFFSET :offset];
        
        return customSerialize(accounts);
    }

    @AuraEnabled
    public static String getProductsDataByOppId(String oppId) {
        List<Map<String, Object>> products = new List<Map<String, Object>>();
                
        for (OpportunityLineItem product : [SELECT Id, Product2.Name, Quantity, TotalPrice
                                            FROM OpportunityLineItem
                                            WHERE OpportunityId =:oppId]) {
            products.add(
                new Map<String, Object> {
                    'id' => product.Id,
                    'name' => product.Product2.Name,
                    'quantity' => product.Quantity,
                    'total' => product.TotalPrice
                }
            );
        }

        return JSON.serializePretty(products);
    }
}