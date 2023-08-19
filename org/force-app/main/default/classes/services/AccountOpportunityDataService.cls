global with sharing class AccountOpportunityDataService {
    private Integer currentPage;
    private String key;
    private Decimal amount;

    private AccountOpportunityDataService(Integer currentPage, String key, Decimal amount) {
        this.currentPage = currentPage;
        this.key = key;
        this.amount = amount;
    }

    private Integer getCount() {
        String[] query = new List<String>{
            'SELECT COUNT(Id) FROM Opportunity'
        };

        if (String.isNotBlank(key)) {
            query.add('WHERE Account.Name LIKE \'' + key + '%\'');
        }

        query.add('GROUP BY Account.Id');

        if (amount != null) {
            query.add('HAVING SUM(Amount)=' + String.valueOf(amount));
        }

        return Database.query(String.join(query, ' ')).size();
    }

    private Pagination getPagination() {
        Integer count = getCount();
        Integer totalPages;
        
        if (Math.mod(count, 10) == 0 && count != 0) {
            totalPages = (Integer) count / 10;
        } else {
            totalPages = (Integer) Math.floor(count / 10) + 1;
        }

        return new Pagination(currentPage, 10, totalPages);
    }

    private PageData getCurrentPage() {
        Pagination pagination = getPagination();
        List<String> accountsNames = new List<String>();
        List<AccountOpportunitiesRecord> records = new List<AccountOpportunitiesRecord>();

        String[] query = new List<String>{
            'SELECT Account.Name Name, SUM(Amount) TotalAmount FROM Opportunity'
        };

        if (String.isNotBlank(key)) {
            query.add('WHERE Account.Name LIKE \'' + key + '%\'');
        }
        query.add('GROUP BY Account.Name');
        if (amount != null) {
            query.add('HAVING SUM(Amount)=' + String.valueOf(amount));
        }
        Integer offset = (currentPage - 1) * 10;
        query.add('LIMIT 10 ' + ' OFFSET ' + offset);

        List<AggregateResult> results = Database.query(String.join(query, ' '));
        
        for (AggregateResult result : results) {
            accountsNames.add((String) result.get('Name'));
        }

        List<Account> accounts = [
            SELECT Account.Id, Account.Name,
            (
                SELECT Opportunity.Id,
                    Opportunity.Name,
                    Opportunity.CreatedDate,
                    Opportunity.CloseDate,
                    Opportunity.Amount
                FROM Opportunities
            )
            FROM Account
            WHERE Account.Name IN :accountsNames
        ];
        
        for (Integer i = 0; i < accounts.size(); i++) {
            records.add(
                new AccountOpportunitiesRecord(accounts.get(i),  (Decimal) results.get(i).get('TotalAmount'))
            );
        }

        return new PageData(new Payload(records), pagination);
    }

    @AuraEnabled
    public static PageData getPageData(Integer p, String key, Decimal amount) {
        AccountOpportunityDataService service = new AccountOpportunityDataService(p, key, amount);
        return service.getCurrentPage();
    }

    @AuraEnabled
    public static AccountOpportunitiesRecord getDataById(Id id){
        Account account = [
            SELECT Account.Id, Account.Name,
            (
                SELECT Opportunity.Id,
                    Opportunity.Name,
                    Opportunity.CreatedDate,
                    Opportunity.CloseDate,
                    Opportunity.Amount
                FROM Opportunities
            )
            FROM Account
            WHERE Account.Id=:id
            LIMIT 1
        ];

        Decimal totalAmount = 0;
        for (Opportunity opportunity : account.Opportunities) {
            totalAmount += opportunity.Amount;
        }
        
        return new AccountOpportunitiesRecord(account, totalAmount);
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getProductsByOppId(String oppId) {
        List<OpportunityLineItem> products = [
            SELECT Id, Product2.Name, Quantity, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId =:oppId
        ];
        
        return products;
    }

    /* Classes of Data Transfer Objects */ 

    global class AccountOpportunitiesRecord {
        @AuraEnabled
        global String title;
        @AuraEnabled
        global Account account;
        @AuraEnabled
        global Decimal totalAmount;

        AccountOpportunitiesRecord(Account account, Decimal totalAmount) {
            this.account = account;
            this.totalAmount = totalAmount;
            this.title = account.Name + '(' + totalAmount + ConnectApi.Organization.getSettings().userSettings.currencySymbol + ')'; 
        }
    }

    global class Payload {
        @AuraEnabled
        global List<AccountOpportunitiesRecord> records;

        Payload(List<AccountOpportunitiesRecord> records) {
            this.records = records;
        }
    }

    global class Pagination {
        @AuraEnabled
        global Integer size;
        @AuraEnabled
        global Integer totalPages; 
        @AuraEnabled
        global Integer currentPage;

        Pagination(Integer currentPage, Integer size, Integer totalPages) {
            this.size = size;
            this.totalPages = totalPages;
            this.currentPage = currentPage;
        }
    }

    
    global class PageData {
        @AuraEnabled
        global Payload payload;
        @AuraEnabled
        global Pagination pagination;

        PageData(Payload payload, Pagination pagination) {
            this.payload = payload;
            this.pagination = pagination;
        }
    }
}