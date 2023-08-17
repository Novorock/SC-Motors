public class SchedulableContactDebugger implements System.Schedulable {
    public void execute(System.SchedulableContext sc) {
    	Database.executeBatch(new BatchableContactDebugger()); 
    }
}