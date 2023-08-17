public class JobSchedulerService implements System.Schedulable {
    private System.Schedulable original;
    
    public JobSchedulerService(System.Schedulable instance) {
        original = instance;
    }
    
    public void execute(System.SchedulableContext sc) {
        original.execute(sc);
       	CronTrigger cronTrigger = [SELECT CronJobDetail.Name FROM CronTrigger WHERE Id=:sc.getTriggerId()];
         // Publish event that job was triggered
       	Database.SaveResult result = EventBus.publish(new AsyncJobChangeEvent__e(
          	JobType__c='ScheduledApex',
          	JobName__c=cronTrigger.CronJobDetail.Name
      	));
            
      	if (result.isSuccess()) {
       		System.debug('Successfully published event.');
     	} else {
         	for (Database.Error err : result.getErrors()) {
           		System.debug(err.getStatusCode() + ' - ' + err.getMessage());
            }
      	}
    }
    
   	@AuraEnabled
    public static AsyncApexJob getJobStatus(String jobName) {
        List<AsyncApexJob> jobs = [
            SELECT ApexClass.Name, CronTrigger.State, CronTrigger.StartTime, CronTrigger.TimesTriggered
            FROM AsyncApexJob WHERE JobType='ScheduledApex' AND CronTrigger.CronJobDetail.Name=:jobName 
        ];
        
        if (jobs.size() < 1) {
            return null;
        }
        
      	return jobs.get(0);
    }
    
    @AuraEnabled
    public static Id schedule(String jobName, String cron, String schedulableClassName) {
        System.Schedulable schedulable = (System.Schedulable) Type.forName(schedulableClassName).newInstance(); 
        return System.schedule(jobName, cron, new JobSchedulerService(schedulable));
    }
    
    @AuraEnabled
    public static Id abort(String jobName) {
		List<CronTrigger> jobs = [
            SELECT Id FROM CronTrigger
            WHERE CronJobDetail.Name=:jobName
        ];
        
        if (jobs.size() < 1) {
            return null;
        }
        
        Id asyncApexJobId = jobs.get(0).Id;
        System.abortJob(asyncApexJobId);
        
        return asyncApexJobId;
    }
}