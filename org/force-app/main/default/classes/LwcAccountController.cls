public with sharing class LwcAccountController {
    public static Integer pagesAmountCalc(Integer recordsAmount) {
        if (Math.mod(recordsAmount, 10) == 0 && recordsAmount != 0) {
            return (Integer) recordsAmount / 10;
        } else {
            return (Integer) Math.floor(recordsAmount / 10) + 1;
        }
    }

    public static String customSerialize(List<Account> container, Integer pagesAmount) {
        List<Map<String, Object>> accounts = new List<Map<String, Object>>(); 
    
        for (Account c : container) {
            Decimal total = 0;

            for (Opportunity opp : c.Opportunities) {
                total += opp.Amount;
            }

            String title = String.format('{0} ({1} €)', new String[]{c.Name, String.valueOf(total)});

            accounts.add(
                new Map<String, Object> {
                    'Id' => c.Id, 'Name' => c.Name, 'Total' => total, 'Title' => title, 'Opportunities' => c.Opportunities
                }
            );
        }     

        return JSON.serialize(
            new Map<String, Object> {'PagesAmount' => pagesAmount, 'Accounts' => accounts}
        );
    }

    @AuraEnabled
    public static String getAccountOpportunityById(String id) {
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
            WHERE Account.Id=:id
        ];
        
        return customSerialize(accounts, 0);
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
        
        return customSerialize(accounts, pagesAmountCalc(recordsAmount));
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
                LIMIT 10 OFFSET :offset
            ];
        }
        
        return customSerialize(accounts, pagesAmountCalc(recordsAmount));
    }

    @AuraEnabled
    public static String getProductsByOppId(String oppId) {
        List<OpportunityLineItem> products = [
            SELECT Id, Product2.Name, Quantity, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId =:oppId
        ];
        
        return JSON.serialize(products);
    }
}