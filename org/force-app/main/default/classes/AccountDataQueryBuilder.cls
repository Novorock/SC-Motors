public with sharing class AccountDataQueryBuilder {
    private Map<String, Object> binds;
    private String limitQuery;
    private String query;
    private List<Id> ids;

    public AccountDataQueryBuilder() {
        binds = new Map<String, Object> {'Lim' => 10};
    }

    private Integer build() {
        String accountQuery = 'SELECT Id FROM Account';

        if (binds.containsKey('AccountId')) {
            
            accountQuery = ':AccountId';

        } else if (binds.containsKey('Name')) {
            if (String.isBlank((String) binds.get('Name')))
                return -1;
            
            accountQuery = accountQuery + ' WHERE Name LIKE :Name';
        }

        String aggQuery = String.format('SELECT AccountId, SUM(Amount) Total FROM Opportunity WHERE AccountId IN ({0}) GROUP BY AccountId',
            new String[] {accountQuery});

        if (binds.containsKey('Total')) {
            aggQuery = aggQuery + ' HAVING SUM(Amount)=:Total';
        }

        this.query = aggQuery;

        if (String.isNotBlank(limitQuery))
            this.query += limitQuery;
        
        return 0;
    }

    public void setNameFilter(String key) {
        binds.put('Name', key + '%');
    }

    public void setTotalPriceFilter(Decimal Total) {
        binds.put('Total', Total);
    }

    public void setIdFilter(String id) {
        binds.put('AccountId', id);
    }

    public void setPage(Integer n) {
        if (n < 1)
            return;

        binds.put('Offset', 
            ((Integer) binds.get('Lim')) * (n - 1)
        );

        limitQuery = ' LIMIT :Lim OFFSET :Offset';
    }

    public List<Object> execute() {
        List<Object> result = new List<Object>();

        if (build() != 0)
            return result;

        List<AggregateResult> agg = (List<AggregateResult>) Database.queryWithBinds(query, binds, AccessLevel.USER_MODE);
        List<Id> ids = new List<Id>();

        for (AggregateResult r : agg) {
            ids.add((Id) r.get('AccountId'));
        }

        Map<Id, Account> accounts = new Map<Id, Account>([
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
        ]);


        for (AggregateResult r : agg) {
            Id id = (Id) r.get('AccountId');
            Account a = accounts.get(id);

            result.add(new Map<String, Object> {
                'Id' => a.Id, 'Name' => a.Name, 'Opportunities' => a.Opportunities, 'Total' => r.get('Total')  
            });
        }

        return result;
    }

    public Integer executeCount() {
        if (build() != 0)
            return 0;

        List<SObject> ids = Database.queryWithBinds(query, binds, AccessLevel.USER_MODE);

        return ids.size();
    }
}