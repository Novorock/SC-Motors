import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import getPageData from '@salesforce/apex/AccountOpportunityDataService.getPageData';
import getDataById from '@salesforce/apex/AccountOpportunityDataService.getDataById';
import LineItemListPopup from 'c/lineItemListPopup';
import recordPageTemplate from './recordPageTemplate.html';
import tabPageTemplate from './tabPageTemplate.html';


export default class LwcAccountSalesList extends NavigationMixin(LightningElement) {
    @api recordId;
    records = [];
    @track
    record = {
        account: {},
        totalAmount: null
    };
    isEmptyList = false;
    pagesTotalAmount = 1;
    key = null;
    price = null;
    popupOpened = false;
    popupTitle = null;
    popupLineItems = null;

    refineCurrentPage(currentPage) {
        getPageData({
            p: currentPage,
            key: this.key,
            amount: this.price
        }).then(pageData => {
            this.records = pageData.payload.records;
            this.pagesTotalAmount = pageData.pagination.totalPages;

            if (this.records.length < 1) {
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
            this.refineCurrentPage(1);

            this.template.addEventListener("newpage", (event) => {
                console.log(`Next page is ${event.detail.page}`);
                this.refineCurrentPage(event.detail.page);
            });

            this.template.addEventListener("quickfind", (event) => {
                console.log(`Quick find is triggered with ${event.detail.name} and ${event.detail.price}`);
                this.key = event.detail.name;
                this.price = event.detail.price;
                this.refineCurrentPage(1);
            });
        } else {
            getDataById({
                id: this.recordId
            }).then((record) => {
                console.log(record);
                this.record = record;
            }).catch((error) => {
                console.log(error)
            });
        }

        this.template.addEventListener("hidepopup", (event) => {
            this.popupOpened = false;
        });
    }

    render() {
        return this.recordId ? recordPageTemplate : tabPageTemplate;
    }

    handleOpenPopup(event) {
        event.target?.blur();

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