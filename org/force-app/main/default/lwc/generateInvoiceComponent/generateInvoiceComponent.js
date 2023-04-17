import {  LightningElement, api, wire } from 'lwc';
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
        if (this.recordId === null || this.recordId === undefined) {
            return;
        }
        
        let showSuccessToast = new ShowToastEvent({
            title: 'Success',
            message: 'Invoice was generated successfully.',
            variant: 'success'
        });

        let showFailToast = new ShowToastEvent({
            title: 'Failure',
            message: 'Error occured during the generating file.',
            variant: 'error'
        }); 

        generateInvoicePdf({
            oppId: this.recordId   
        }).then(result => {
            this.dispatchEvent(showSuccessToast);
        }).catch(error => {
            this.dispatchEvent(showFailToast);
            console.log(error);
        });
    }
}