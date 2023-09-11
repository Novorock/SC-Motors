@IsTest
public with sharing class UnitOfWorkSubscribableRepositoryTest {
    @TestSetup
    private static void setup() {
    	List<Opportunity> opportunities = new List<Opportunity>();
        
        for (Integer i = 0; i < 3; i++) {
        	opportunities.add(new Opportunity(Name='Opportunity' + i, StageName='Prospecting', Amount=1, CloseDate=Date.today().addDays(5)));  
        }
        
        insert opportunities;
    }

    @IsTest
    private static void testRefine() {
        PublishingUnitOfWork uow = new PublishingUnitOfWork();
        UnitOfWorkSubscribableRepository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
        repository.fetch(new OpportunityQueryByName(new Set<String>{
            'Opportunity0', 'Opportunity1', 'Unexisted Opportunity'
        }));
        uow.subscribe(repository);

        Opportunity opportunity = [SELECT Name FROM Opportunity WHERE Name='Opportunity1' LIMIT 1];

        opportunity.Name='Test1';
        uow.registerOfModified(opportunity);
        System.assertEquals(opportunity.Name, ((Opportunity) repository.getById(opportunity.Id)).Name);
        
        opportunity.Name = 'Test2';
        uow.registerOfModified(opportunity);
        System.assertEquals(opportunity.Name, ((Opportunity) repository.getById(opportunity.Id)).Name);

        uow.registerOfDeleted(opportunity);
        System.assertEquals(null, repository.getById(opportunity.Id));

        uow.commitWork();
    }

    @IsTest
    private static void testGetByName() {
        UnitOfWorkSubscribableRepository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
        repository.fetch(new OpportunityQueryByName(new Set<String>{
            'Opportunity1'
        }));
        
        Opportunity opportunity = [SELECT Name FROM Opportunity WHERE Name='Opportunity1' LIMIT 1];
        List<Opportunity> elements = (List<Opportunity>) repository.getByName('Opportunity1');
        
        System.assertEquals(1, elements.size());
        System.assertEquals(opportunity.Name, elements.get(0).Name);
    }
}