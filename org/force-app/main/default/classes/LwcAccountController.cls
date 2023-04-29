public with sharing class LwcAccountController {
    @AuraEnabled
    public static String getDataByPage(Integer p, String key, String totalPrice) {
		AccountDataQueryBuilder builder = new AccountDataQueryBuilder();

        if (String.isNotBlank(key)) {
            builder.setNameFilter(key);
        }

        if (String.isNotBlank(totalPrice)) {
            if (totalPrice.isNumeric())
                builder.setTotalPriceFilter(Decimal.valueOf(totalPrice));
        }

        builder.setPage(p);

        List<Object> result = builder.execute();

        return JSON.serializePretty(result);
    }

    @AuraEnabled
    public static String getDataById(String id) {
        AccountDataQueryBuilder builder = new AccountDataQueryBuilder();

        if (String.isNotBlank(id)) {
            builder.setIdFilter(id);
            
            List<Object> result = builder.execute();
            
            return JSON.serializePretty(result);
        }

        return JSON.serialize(new List<Object>());
    }

    @AuraEnabled
    public static Integer getPagesTotalAmount(String key, String totalPrice) {
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
    public static String getProductsByOppId(String oppId) {
        List<OpportunityLineItem> products = [
            SELECT Id, Product2.Name, Quantity, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId =:oppId
        ];
        
        return JSON.serialize(products);
    }
}