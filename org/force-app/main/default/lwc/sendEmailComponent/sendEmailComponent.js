import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { CloseActionScreenEvent } from 'lightning/actions'
import { NavigationMixin } from 'lightning/navigation'
import getEmailData from '@salesforce/apex/InvoiceMailer.getEmailData';
import getRelatedInvoicePdfId from '@salesforce/apex/InvoiceMailer.getRelatedInvoicePdfId';
import sendEmail from '@salesforce/apex/InvoiceMailer.sendEmail';

export default class SendEmailComponent extends LightningElement {
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
        var component = this;

        getEmailData({
            oppId: component.recordId
        }).then(result => {
            let data = result;
            component.emailSubject = data.subject;
            component.emailBody = data.body;

            component.recipientId = data.recipient.Id;
            component.recipientName = data.recipient.Name;
            component.recipientEmail = data.recipient.Email;
        }).catch(error => {
            console.log(error);
        })
    }

    handleChange(event) {
        this.emailBody = event.target.value;
    }

    handlePreview() {
        var component = this;

        getRelatedInvoicePdfId({
            oppId: component.recordId
        }).then(id => {
            console.log(`Preview: ${id}`);

            component[NavigationMixin.Navigate]({
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
            component.dispatchEvent(new ShowToastEvent({
                title: 'Failure',
                message: 'Errors occured during the file opening: ' + error.body.message,
                variant: 'error'
            }));
        });
    }

    handleSend() {
        var component = this;

        sendEmail({
            subject: component.emailSubject,
            body: component.emailBody,
            recipientId: component.recipientId,
            relatedToId: component.recordId
        }).then(result => {
            component.dispatchEvent(new CloseActionScreenEvent());
            component.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Message was sent successfully.',
                variant: 'success'
            }));
        }).catch(error => {
            console.log(error);
            component.dispatchEvent(new ShowToastEvent({
                title: 'Failure',
                message: 'Error occurred during the email sending: ' + error.body.message,
                variant: 'error'
            }));
        });
    }
}