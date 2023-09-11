@IsTest
public with sharing class PublishingUnitOfWorkTest {
    @TestSetup
    private static void setup() {
    	List<Opportunity> opportunities = new List<Opportunity>();
        
        String stage = 'Prospecting';
        Date closeDate = Date.today().addDays(5);
        
        for (Integer i = 0; i < 3; i++) {
        	opportunities.add(new Opportunity(Name='Opportunity' + i, StageName=stage, Amount=200, CloseDate=closeDate));  
        }
        
        insert opportunities;
    }

    @IsTest
    private static void testSubscribeUnsubscribe() {
        PublishingUnitOfWork uow = new PublishingUnitOfWork();
        UnitOfWorkSubscribableRepository repository = new UnitOfWorkSubscribableRepository(Opportunity.getSObjectType());
        
        uow.subscribe(repository);
        System.assert(uow.subscribers.size() > 0);

        uow.unsubsribe(repository);
        System.assert(uow.subscribers.size() < 1);
    }   

    @IsTest
    private static void testRegisterOfNew() {
        PublishingUnitOfWork uow = new PublishingUnitOfWork();

        Opportunity opportunity = new Opportunity(
            Name='Test',
            StageName='Prospecting',
            Amount=1,
            CloseDate=Date.today().addDays(1)
        );

        Contact contact = new Contact(LastName='Contact');

        uow.registerOfNew(opportunity);
        uow.registerOfNew(contact);
        uow.commitWork();

        Integer count = [SELECT COUNT() FROM Opportunity];

        System.assertEquals(4, count);

        count = [SELECT COUNT() FROM Contact];

        System.assertEquals(1, count);
    }
    
    @IsTest
    private static void testRegisterOfModified() {
        PublishingUnitOfWork uow = new PublishingUnitOfWork();

        Opportunity opportunity = [SELECT Name FROM Opportunity WHERE Name='Opportunity1'];
        Contact contact = new Contact(LastName='Contact');
        insert contact;

        opportunity.Name='Test1';
        uow.registerOfModified(opportunity);
        
        opportunity.Name = 'Test2';
        uow.registerOfModified(opportunity);
        
        contact.LastName = 'TestContact';
        uow.registerOfModified(contact);
        uow.commitWork();

        opportunity = [SELECT Name FROM Opportunity WHERE Id=:opportunity.Id];
        System.assertEquals('Test2', opportunity.Name);

        Integer count = [SELECT COUNT() FROM Contact WHERE Name='TestContact'];
        System.assertEquals(1, count);
    } 

    @IsTest
    private static void testRegisterOfDeleted() {
        PublishingUnitOfWork uow = new PublishingUnitOfWork();

        Opportunity opportunity = [SELECT Name FROM Opportunity WHERE Name='Opportunity1'];
        uow.registerOfDeleted(opportunity);
        uow.commitWork();
        Integer count = [SELECT COUNT() FROM Opportunity WHERE Id=:opportunity.Id];
        System.assertEquals(0, count);
    }
    
    @IsTest
    private static void testRollback() {
        PublishingUnitOfWork uow = new PublishingUnitOfWork();

        Opportunity opportunity = new Opportunity(
            Name='Test',
            StageName='Prospecting',
            Amount=1,
            CloseDate=Date.today().addDays(1)
        );

        uow.registerOfNew(opportunity);
        uow.commitWork();
        uow.rollback();

        Integer count = [SELECT COUNT() FROM Opportunity];

        System.assertEquals(3, count);
    }
}