 global class EmailInvoiceApproval implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

            String subject = email.subject.trim();
            Pattern InvoiceSubjectPattern = Pattern.compile('INV-\\d{6}');
            Matcher SubjectMatcher = InvoiceSubjectPattern.matcher(subject);  
            
            if (SubjectMatcher.matches()) {
                Opportunity opp = [
                    SELECT Id, StageName
                    FROM Opportunity
                    WHERE Invoice_Number__c=:subject
                ];
                
                if (opp.StageName.equals('Prospecting')) {
                    String body = email.plainTextBody.toLowerCase();
                    Boolean approved = body.contains('approved');
                    Boolean rejected = body.contains('rejected');

                    if (approved) {
                        Schema.DescribeFieldResult field =
                        Opportunity.StageName.getDescribe();
    
                        List<Schema.PicklistEntry> picklist =
                        field.getPicklistValues();
    
                        for (Integer i = 0; i < picklist.size() - 1; i++) {
                            if (picklist.get(i).getValue().equals(opp.StageName)) {
                                opp.StageName = picklist.get(i + 1).getValue();
                                break;
                            }
                        }

                        update opp;
                    } else if (rejected) {
                        opp.StageName = 'Closed Lost';
                        update opp;
                    } else {
                        System.debug('No answered marked.');
                    }
                }
            } else {
                System.debug('Subject is not about approval of the invoice.');
            }
            
            result.success = true;

            return result;
        }
}