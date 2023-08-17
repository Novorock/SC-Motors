public class BatchableContactDebugger implements Database.Batchable<Contact> {
    public Iterable<Contact> start(Database.BatchableContext bc) {
        return [SELECT Name FROM Contact];
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        for (Contact contact : scope) {
            System.debug('Contact<Name="' + contact.Name + '">');
        }
    }
    
    public void finish(Database.BatchableContext bc) {}
}