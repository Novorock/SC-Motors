import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import generateInvoicePdf from '@salesforce/apex/GenerateInvoice.generateInvoicePdf'

export default class GenerateInvoiceComponent extends LightningElement {
    @api recordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @api invoke() {
        var component = this;

        if (component.recordId === null || component.recordId === undefined) {
            return;
        }

        component.dispatchEvent(new ShowToastEvent({
            title: 'Note',
            message: 'The file generating can take some time.',
        }));

        generateInvoicePdf({
            oppId: component.recordId
        }).then(result => {
            component.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Invoice was generated successfully.',
                variant: 'success'
            }));
        }).catch(error => {
            component.dispatchEvent(new ShowToastEvent({
                title: 'Failure',
                message: 'Error occured during the file generating: ' + error.body.message,
                variant: 'error'
            }));
            console.log(error);
        });
    }
}