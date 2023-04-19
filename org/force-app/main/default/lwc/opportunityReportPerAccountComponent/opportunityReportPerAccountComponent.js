import { LightningElement, api} from 'lwc';
import getAccountOpportunityPage from '@salesforce/apex/OpportunityReportPerAccountController.getAccountOpportunityPage';
import getProductsDataByOppId from '@salesforce/apex/OpportunityReportPerAccountController.getProductsDataByOppId';
import getAccountOpportunityPageFiltered from '@salesforce/apex/OpportunityReportPerAccountController.getAccountOpportunityPageFiltered';
import getAccountOpportunityById from '@salesforce/apex/OpportunityReportPerAccountController.getAccountOpportunityById';

export default class OpportunityReportPerAccountComponent extends LightningElement {
    // Record Page Stuff
    @api recordId;
    @api isRecordPage = false;
    @api currentRecord = {};

    // Custom Lightning Tab Stuff 
    @api accountsList
    pagesAmount;
    @api currentPage = 1;
    isPaginationShown = false;
    isModalOpen = false;
    @api modalContext = {
        title: '',
        products: [],
        empty: true
    };
    @api searchContext = {
        accountName: '',
        priceFrom: 0,
        priceTo: 0
    };
    searchTimeout = 0;

    connectedCallback() {
        var component = this;
        // Initial data retrieve

        if (!component.recordId) {
            getAccountOpportunityPage({
                pageN: 1,
            }).then(result => {
                let data = JSON.parse(result);
                component.accountsList = data.accounts;
                component.pagesAmount = data.pagesAmount;
                component.isPaginationShown = (this.pagesAmount) > 1;
            }).catch(error => {
                console.log(error);
            });
        } else {
            component.isRecordPage = true;

            getAccountOpportunityById({
                id: component.recordId
            }).then(result => {
                component.currentRecord = JSON.parse(result).accounts[0];
            }).catch(error => {
                console.log(error);
            });
        }
    }

    retrieveAndUpdate() {
        var component = this;

        if (!component.searchContext.accountName && !component.searchContext.priceFrom && !component.searchContext.priceTo) {
            
            getAccountOpportunityPage({
                pageN: component.currentPage,
            }).then(result => {
                let data = JSON.parse(result);
                component.accountsList = data.accounts;
                component.pagesAmount = data.pagesAmount;
                component.isPaginationShown = (component.pagesAmount) > 1;
            }).catch(error => {
                console.log(error);
            });
        } else {
            getAccountOpportunityPageFiltered({
                pageN: component.currentPage,
                searchTokens: component.searchContext.accountName,
                min: component.searchContext.priceFrom,
                max: component.searchContext.priceTo
            }).then(result => {
                let data = JSON.parse(result);
                component.accountsList = data.accounts;
                component.pagesAmount = data.pagesAmount;
                component.isPaginationShown = (component.pagesAmount) > 1;
            }).catch(error => {
                console.log(error);
            });
        }
    }

    handleNextPage(event) {
        if ((this.currentPage + 1) <= this.pagesAmount) {
            this.currentPage += 1;
            this.retrieveAndUpdate();
        }
    }

    handlePreviousPage(event) {
        if ((this.currentPage - 1) > 0) {
            this.currentPage -= 1;
            this.retrieveAndUpdate();
        }
    }

    handleAccountNameChange(event) {
        var component = this;

        clearTimeout(component.searchTimeout);
        component.searchContext.accountName = event.target.value.trim();

        component.searchTimeout = setTimeout(() => {
            if (event.target.value !== component.searchContext.accountName) {
                component.currentPage = 1;
                component.retrieveAndUpdate();
            }
        }, 1500);
    }

    handleTotalPriceFromChange(event) {
        var component = this;

        clearTimeout(component.searchTimeout);
        component.searchContext.priceFrom = parseInt(event.target.value.trim());

        component.searchTimeout = setTimeout(() => {
            component.currentPage = 1;
            component.retrieveAndUpdate();
        }, 1500);
    }

    handleTotalPriceToChange(event) {
        var component = this;

        clearTimeout(component.searchTimeout);
        component.searchContext.priceTo = parseInt(event.target.value.trim());

        component.searchTimeout = setTimeout(() => {
            component.currentPage = 1;
            component.retrieveAndUpdate();
        }, 1500);
    }

    openModal(event) {
        var component = this;

        let title = event.target.dataset.title;

        getProductsDataByOppId({
            oppId: event.target.dataset.id
        }).then(data => {
            let products = JSON.parse(data);
            component.modalContext.title = title;
            component.modalContext.empty = (products.length < 1);
            component.modalContext.products = products;
            component.isModalOpen = true;
        }).catch(error => {
            console.log(error);
        });
    }

    closeModal(event) {
        this.isModalOpen = false;
    }
}