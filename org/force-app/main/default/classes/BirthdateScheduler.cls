public class BirthdateScheduler implements System.Schedulable {
    public void execute(System.SchedulableContext sc) {
  		Database.executeBatch(new BirthdateCongratulator(), 10);
    }
    
    public Id run() {
        String cron = '0 0 6 * * ? *';
        return System.schedule('Birthdate congratulator', cron, this);
    }
}