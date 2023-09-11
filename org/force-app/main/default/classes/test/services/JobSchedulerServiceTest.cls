@IsTest
public class JobSchedulerServiceTest implements System.Schedulable {
    @TestSetup
    private static void setup() {
        
    }
    
    public void execute(SchedulableContext sc) {
        System.debug('This is a stub');
    }
    
    @IsTest
    private static void testSchedule() {
        Test.startTest();
        Id cronId = JobSchedulerService.schedule('Test Job', '0 0 0 * * ? *', 'JobSchedulerServiceTest');
        Test.stopTest();
        List<CronTrigger> cronTrigger = [SELECT Id FROM CronTrigger WHERE Id=:cronId];
        System.assertEquals(1, cronTrigger.size());
    }
    
    @IsTest
    private static void testGetJobStatus() {
		AsyncApexJob job = JobSchedulerService.getJobStatus('Test Job');
        System.assertEquals(null, job);
        
        Test.startTest();
        Id cronId = JobSchedulerService.schedule('Test Job', '0 0 0 * * ? *', 'JobSchedulerServiceTest');
        Test.stopTest();
        
        job = JobSchedulerService.getJobStatus('Test Job');
        System.assertNotEquals(null, job);
    }
    
    @IsTest
    private static void testAbort() {        
        Test.startTest();
        JobSchedulerService.schedule('Test Job', '0 0 0 * * ? *', 'JobSchedulerServiceTest');
        Test.stopTest();
        
        Id cronId = JobSchedulerService.abort('Unexisted');
        System.assertEquals(null, cronId);
        
        cronId = JobSchedulerService.abort('Test Job');
        List<CronTrigger> cronTrigger = [SELECT Id FROM CronTrigger WHERE Id=:cronId];
        System.assertEquals(0, cronTrigger.size());
    }
}