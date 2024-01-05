trigger OnNewPayment on Payment__c (after insert) {
	Set<String> keys = new Set<String>();
	
	for (Payment__c payment : Trigger.new) {
		keys.add(payment.OpportunityName__c);
	}

	PublishingUnitOfWork uow = new PublishingUnitOfWork();
	UnitOfWorkSubscribableRepository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
	uow.subscribe(repository);
	repository.fetch(new OpportunityQueryByName(keys));

	for (Payment__c payment : Trigger.new) {
		new PaymentOperation(payment, repository).performWith(uow);
	}

	uow.commitWork();
}