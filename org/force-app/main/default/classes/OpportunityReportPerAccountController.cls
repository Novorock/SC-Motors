public with sharing class OpportunityReportPerAccountController {
    public static String customSerialize(List<Account> accounts, Integer pagesAmount) {
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

        return JSON.serializePretty(
            new Map<String, Object> {
                'pagesAmount' => pagesAmount,
                'accounts' => batch
            }
        );
    }

    @AuraEnabled
    public static String getAccountOpportunityPage(Integer pageN) {
        List<AggregateResult> results = [SELECT AccountId FROM Opportunity GROUP BY AccountId];
        
        List<Id> ids = new List<Id>();
        for (AggregateResult ar : results) {
            ids.add((Id) ar.get('AccountId'));
        }

        Integer offset = 10 * (pageN - 1);
        Integer recordsAmount = ids.size();
        Integer pagesAmount;

        List<Account> accounts = [
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
            WHERE Account.Id IN :ids
            LIMIT 10 OFFSET :offset
        ];
        
        if (Math.mod(recordsAmount, 10) == 0) {
            pagesAmount = (Integer) recordsAmount / 10;
        } else {
            pagesAmount = (Integer) Math.floor(recordsAmount / 10) + 1;
        }
        
        return customSerialize(accounts, pagesAmount);
    }

    @AuraEnabled
    public static String getAccountOpportunityPageFiltered(Integer pageN, String searchTokens, Integer min, Integer max) {
        if (String.isBlank(searchTokens) && min == null && max == null) {
            throw new AuraHandledException('Filter is undefined. Retrieve data without the filtering.');
        }

        if (min < 0 || min == null) {
            min = 0;
        }

        if (max <= 0 || max <= min || max == null) {
            max = 2147483647;
        }

        List<AggregateResult> results = [
            SELECT AccountId
            FROM Opportunity
            GROUP BY AccountId
            HAVING SUM(AMOUNT) > :min AND SUM(AMOUNT) < :max
        ];
        
        List<Id> idsFilteredByTotalPrice = new List<Id>();
        for (AggregateResult ar : results) {
            idsFilteredByTotalPrice.add((Id) ar.get('AccountId'));
        }
        
        List<Account> accounts;
        Integer offset = 10 * (pageN - 1);
        Integer recordsAmount;
        Integer pagesAmount;

        if (String.isNotBlank(searchTokens)) {
            String criteria = searchTokens + '%';
            recordsAmount = Database.countQuery('SELECT COUNT() FROM Account WHERE Name LIKE :criteria AND Id IN :idsFilteredByTotalPrice');

            accounts = [
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
                WHERE Account.Id IN :idsFilteredByTotalPrice
                AND Account.Name LIKE :criteria 
                LIMIT 10 OFFSET :offset
            ];
        } else {
            recordsAmount = idsFilteredByTotalPrice.size();

            accounts = [
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
                WHERE Account.Id IN :idsFilteredByTotalPrice
                LIMIT 10 OFFSET :offset];
        }

        if (Math.mod(recordsAmount, 10) == 0) {
            pagesAmount = (Integer) recordsAmount / 10;
        } else {
            pagesAmount = (Integer) Math.floor(recordsAmount / 10) + 1;
        }
        
        return customSerialize(accounts, pagesAmount);
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