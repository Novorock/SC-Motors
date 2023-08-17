import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import getProductsByOppId from '@salesforce/apex/LwcAccountController.getProductsByOppId';

export default class LineItemListPopup extends LightningModal {
    @api opportunityId;
    items;
    empty = false;

    connectedCallback() {
        getProductsByOppId({
            oppId: this.opportunityId
        })
        .then((result) => {
            this.items = result;
            this.empty = (this.items.length < 1);
        }).catch((error) => {
            console.log(error);
        })
    }
}