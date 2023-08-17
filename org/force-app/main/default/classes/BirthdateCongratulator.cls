public class BirthdateCongratulator implements Database.Batchable<Contact>, Database.Stateful {
    @TestVisible
    public static Integer emailInvocations;
    
    public BirthdateCongratulator() {
    	BirthdateCongratulator.emailInvocations = 0;
    }
    
    public Iterable<Contact> start(Database.BatchableContext bc) {
    	return [SELECT Name, Email, Birthdate, OwnerId FROM Contact];
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        /*if (scope.size() > 10) {
			IllegalArgumentException e = new IllegalArgumentException();
			e.setMessage('Batch size for this job must be less than 10. Actual: ' + scope.size());
			System.abortJob(bc.getJobId());
            throw e;
        }*/
		
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, Subject, Body FROM EmailTemplate WHERE Name='Birthdate Congratulation'];
        List<String> body = new List<String>{template.Body};
        Id stub = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
        for (Contact contact : scope) {
            if (contact.Birthdate != null && contact.Birthdate.month() == System.now().month() && contact.Birthdate.day() == System.now().day()) {
                if (contact.Email == null) {
                    continue;
                }
                
            	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                Messaging.RenderEmailTemplateBodyResult renderedEmail = Messaging.renderEmailTemplate(contact.Id, stub, body)[0];
                message.setHtmlBody(renderedEmail.getMergedBody());
                message.setSubject(template.Subject);
            	message.setToAddresses(new List<String>{contact.Email});
        		messages.add(message);    
            }
        }
        
        if (messages.size() > 0) {
        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
        	for (Messaging.SendEmailResult result : results) {
            	if (!result.isSuccess()) {
                	List<Messaging.SendEmailError> errors = result.getErrors();
                	System.debug(String.join(errors, '; '));
                } else {
                    System.debug('Email message was sent successfuly');
                    
                    if (Test.isRunningTest()) {
                    	BirthdateCongratulator.emailInvocations++;   
                    }
                }
        	}    
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    }
}