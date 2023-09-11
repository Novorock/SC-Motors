@IsTest
public with sharing class RepositoryTest {
    @TestSetup
    private static void setup() {
    	List<Opportunity> opportunities = new List<Opportunity>();
        
        String stage = 'Prospecting';
        Date closeDate = Date.today().addDays(5);

        for (Integer i = 0; i < 3; i++) {
            opportunities.add(new Opportunity(
                    Name='Opportunity' + i,
                    StageName=stage,
                    Amount=200,
                    CloseDate=closeDate
                )
            );
        }

        insert opportunities;  
    }

    @IsTest
    private static void testGetById() {
        List<Opportunity> items = [SELECT Name FROM Opportunity];
        Repository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
        repository.fetch(new OpportunityQueryByName(new Set<String>{
            'Opportunity0', 'Opportunity1', 'Unexisted Opportunity'
        }));
        
        Id id = items.get(0).Id;
        System.assertEquals(items.get(0).Id, repository.getById(id).Id);
        id = items.get(2).Id;
        System.assertEquals(null, repository.getById(id));
    }

    @IsTest
    private static void testAdd() {
        Repository repository = new UnitOfWorkSubscribableRepository(Contact.getSObjectType());

        try {
            repository.add(new Contact(LastName='Test'));
            System.assert(false, 'Unsupported operation exception expected.');
        } catch(UnsupportedOperationException e) {
        }
    }

    @IsTest
    private static void testModify() {
        Opportunity opportunity = [SELECT Name FROM Opportunity LIMIT 1];

        Repository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
        repository.fetch(new OpportunityQueryByName(new Set<String>{
            'Opportunity0'
        }));

        Id id = opportunity.Id;

        System.assertEquals(opportunity.Name, ((Opportunity) repository.getById(id)).Name);
        opportunity.Name = 'Test';
        repository.modify(opportunity);
        System.assertEquals(opportunity.Name, ((Opportunity) repository.getById(id)).Name);

        Opportunity obj = new Opportunity(
            Name='Unmodifiable',
            StageName='Prospecting',
            Amount=1,
            CloseDate=Date.today().addDays(1)
        );

        try {
            repository.modify(obj);
            System.assert(false, 'Modifiable object has to contain identifier. Exception expected.');
        } catch (Exception e) {
        }
    }
    
    @IsTest
    private static void testRemove() {
        Opportunity opportunity = [SELECT Name FROM Opportunity LIMIT 1];

        Repository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
        repository.fetch(new OpportunityQueryByName(new Set<String>{
            'Opportunity0'
        }));

        Id id = opportunity.Id;
        repository.remove(opportunity);
        System.assertEquals(null, repository.getById(id));

        repository.remove(opportunity);
        System.assertEquals(null, repository.getById(id));
    }
}