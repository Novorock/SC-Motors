public with sharing class LwcAccountController {
    @AuraEnabled
    public static List<Object> getAccountListPage(Integer p, String key, String totalPrice) {
		AccountDataQueryBuilder builder = new AccountDataQueryBuilder();

        if (String.isNotBlank(key)) {
            builder.setNameFilter(key);
        }

        if (String.isNotBlank(totalPrice)) {
            if (totalPrice.isNumeric())
                builder.setTotalPriceFilter(Decimal.valueOf(totalPrice));
        }

        builder.setPage(p);
        
        return builder.execute();
    }

    @AuraEnabled
    public static Object getAccountById(String id) {
        AccountDataQueryBuilder builder = new AccountDataQueryBuilder();
        builder.setIdFilter(id);
        List<Object> result = builder.execute();
        if (result.size() > 0) {
            return result.get(0);
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Integer getAccountListPagesAmount(String key, String totalPrice) {
    	AccountDataQueryBuilder builder = new AccountDataQueryBuilder();
        
        if (String.isNotBlank(key)) {
            builder.setNameFilter(key);
        }

        if (String.isNotBlank(totalPrice)) {
            if (totalPrice.isNumeric())
                builder.setTotalPriceFilter(Decimal.valueOf(totalPrice));
        }

        Integer count = builder.executeCount();

        if (Math.mod(count, 10) == 0 && count != 0) {
            return (Integer) count / 10;
        } else {
            return (Integer) Math.floor(count / 10) + 1;
        }
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
}