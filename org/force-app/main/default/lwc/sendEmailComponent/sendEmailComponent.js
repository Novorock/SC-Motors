import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { CloseActionScreenEvent } from 'lightning/actions'
import { NavigationMixin } from 'lightning/navigation'
import getEmailData from '@salesforce/apex/InvoiceMailer.getEmailData';
import getRelatedInvoicePdfId from '@salesforce/apex/InvoiceMailer.getRelatedInvoicePdfId';
import sendEmail from '@salesforce/apex/InvoiceMailer.sendEmail';

export default class SendEmailComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    emailSubject;

    emailBody;
    allowedFormats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'list',
        'indent',
        'link'
    ]

    recipientId;
    recipientName;
    recipientEmail;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        getEmailData({
            oppId: this.recordId
        }).then(result => {
            let data = result;
            this.emailSubject = data.subject;
            this.emailBody = data.body;

            this.recipientId = data.recipient.Id;
            this.recipientName = data.recipient.Name;
            this.recipientEmail = data.recipient.Email;
        }).catch(error => {
            console.log(error);
        })
    }

    handleChange(event) {
        this.emailBody = event.target.value;
    }

    handlePreview() {
        getRelatedInvoicePdfId({
            oppId: this.recordId
        }).then(id => {
            console.log(`Preview: ${id}`);

            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: id
                }
            });
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Failure',
                message: 'Errors occured during the file opening: ' + error.body.message,
                variant: 'error'
            }));
        });
    }

    handleSend() {
        sendEmail({
            subject: this.emailSubject,
            body: this.emailBody,
            recipientId: this.recipientId,
            relatedToId: this.recordId
        }).then(result => {
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Message was sent successfully.',
                variant: 'success'
            }));
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Failure',
                message: 'Error occurred during the email sending: ' + error.body.message,
                variant: 'error'
            }));
        });
    }
}