@IsTest
public class BirthdateSchedulerTest {
    @IsTest
    private static void testRun() {
        Test.startTest();
        Id cronId = new BirthdateScheduler().run();
		Test.stopTest();
        List<CronTrigger> cronTrigger = [SELECT Id FROM CronTrigger WHERE Id=:cronId];
        System.assertEquals(1, cronTrigger.size());
    }
}