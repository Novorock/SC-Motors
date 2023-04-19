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

    @api emailBody;
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
        })
            .then(result => {
                let data = JSON.parse(result);
                this.emailSubject = data.subject;
                this.emailBody = data.body;

                this.recipientId = data.recipient.id;
                this.recipientName = data.recipient.name;
                this.recipientEmail = data.recipient.email;
            })
            .catch(error => {
                console.log(error);
            })
    }

    handleChange(event) {
        this.emailBody = event.target.value;
    }

    handlePreview() {
        getRelatedInvoicePdfId({
            oppId: this.recordId
        })
            .then(id => {
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
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Failure',
                    message: 'Errors occured during open file. Possibly, file was not generated.',
                    variant: 'error'
                }));
            });
    }

    handleSend() {
        let showSuccessToast = new ShowToastEvent({
            title: 'Success',
            message: 'Message was sent successfully.',
            variant: 'success'
        });

        let showFailToast = new ShowToastEvent({
            title: 'Failure',
            message: 'Error occurred during sending message. Please, try later or check recipient email.',
            variant: 'error'
        });

        sendEmail({
            subject: this.emailSubject,
            body: this.emailBody,
            recipientId: this.recipientId,
            relatedToId: this.recordId
        })
            .then(result => {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(showSuccessToast);
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(showFailToast);
            });
    }
}