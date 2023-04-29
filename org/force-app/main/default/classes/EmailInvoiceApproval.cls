global class EmailInvoiceApproval implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.inboundEmail email, Messaging.InboundEnvelope env) {
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

            String subject = email.subject.trim();
            Pattern InvoiceSubjectPattern = Pattern.compile('INV-\\d{6}');
            Matcher SubjectMatcher = InvoiceSubjectPattern.matcher(subject);  
            
            if (SubjectMatcher.find()) {
                String invoiceNumber = subject.substring(SubjectMatcher.start(), SubjectMatcher.end());
                
                Opportunity opp = [
                    SELECT Id, StageName
                    FROM Opportunity
                    WHERE Invoice_Number__c=:invoiceNumber
                ];
                
                
                String body = email.plainTextBody.toLowerCase();
                    
                // The inbound message can contains several marks of 'approved' or 'rejected' answer,
                // since the original text can be included. 
                Integer approvedCounter = body.countMatches('approved');
				Integer rejectedCounter = body.countMatches('rejected');

                if (approvedCounter > rejectedCounter && approvedCounter != 0) {
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
                } else if (rejectedCounter != 0) {
                    opp.StageName = 'Closed Lost';
                    update opp;
                } else {
                    System.debug('No answered marked.');
                }
            }
            
            result.success = true;

            return result;
        }
}