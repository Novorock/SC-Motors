import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import getAccountListPage from '@salesforce/apex/LwcAccountController.getAccountListPage';
import getAccountById from '@salesforce/apex/LwcAccountController.getAccountById';
import getAccountListPagesAmount from '@salesforce/apex/LwcAccountController.getAccountListPagesAmount';
import LineItemListPopup from 'c/lineItemListPopup';

export default class LwcAccountSalesList extends NavigationMixin(LightningElement) {
    @api recordId;
    isRecordPage = false;
    accountData = [];
    isEmptyList = false;

    currentPage = 1;
    pagesTotalAmount = 10;

    key = null;
    price = null;

    popupOpened = false;
    popupTitle = null;
    popupLineItems = null;

    refinePagesTotalAmount() {
        getAccountListPagesAmount({
            key: this.key,
            totalPrice: this.price
        }).then(pagesAmount => {
            this.pagesTotalAmount = JSON.parse(pagesAmount);
        }).catch(error => {
            console.log(error);
        });
    }

    retrieveCurrentAccountList() {
        getAccountListPage({
            p: this.currentPage,
            key: this.key,
            totalPrice: this.price
        }).then(result => {
            this.accountData = result;

            for (let i = 0; i < this.accountData.length; i++) {
                let item = this.accountData[i];
                item.Title = `${item.Name} (${item.Total} €)`;
            }

            if (this.accountData.length < 1) {
                this.isEmptyList = true;
            } else {
                this.isEmptyList = false;
            }
        }).catch(error => {
            console.log(error);
        });
    }

    connectedCallback() {
        if (!this.recordId) {
            this.currentPage = 1;
            this.refinePagesTotalAmount();
            this.retrieveCurrentAccountList(null, null);
        } else {
            this.isRecordPage = true;

            getAccountById({
                id: this.recordId
            }).then(result => {
                this.accountData = result;
            }).catch(error => {
                console.log(error);
            });
        }

        this.template.addEventListener("newpage", (event) => {
            console.log(`Next page is ${event.detail.page}`);
            this.currentPage = event.detail.page;
            this.retrieveCurrentAccountList();
        });

        this.template.addEventListener("quickfind", (event) => {
            console.log(`Quick find is triggered with ${event.detail.name} and ${event.detail.price}`);
            this.key = event.detail.name;
            this.price = event.detail.price;
            this.currentPage = 1;
            this.refinePagesTotalAmount();
            this.retrieveCurrentAccountList();
        });

        this.template.addEventListener("hidepopup", (event) => {
            this.popupOpened = false;
        });
    }

    async handleOpenPopup(event) {
        LineItemListPopup.open({
            label: event.target.dataset.title,
            size: "small",
            opportunityId: event.target.dataset.id 
        });
    }

    handleRedirect(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
}