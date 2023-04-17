import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { CloseActionScreenEvent }  from 'lightning/actions'
import { NavigationMixin } from 'lightning/navigation'
import getEmailData from '@salesforce/apex/InvoiceMailer.getEmailData';
import sendEmail from '@salesforce/apex/InvoiceMailer.sendEmail';

export default class SendEmailComponent extends LightningElement {
    @api recordId;
    @api emailSubject;

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
    @api recipientName;
    @api recipientEmail;

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
        console.log('preview');
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__namedPage',
        //     attributes: {
        //         pageName: 'filePreview'
        //     },
        //     state: {
        //         selectedRecordId: 
        //     }
        // });
    }

    handleSend() {
        let showSuccessToast = new ShowToastEvent({
            title: 'Success',
            message: 'Message was sent successfuly.',
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