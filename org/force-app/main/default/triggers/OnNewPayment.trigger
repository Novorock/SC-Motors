trigger OnNewPayment on Payment__c (after insert) {
	BulkPaymentOperation operation = new BulkPaymentOperation(Trigger.new);
	operation.perform();
}