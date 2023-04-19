import { LightningElement, api } from 'lwc';
import getAccountOpportunityPage from '@salesforce/apex/OpportunityReportPerAccountController.getAccountOpportunityPage';
import getProductsDataByOppId from '@salesforce/apex/OpportunityReportPerAccountController.getProductsDataByOppId';
import getAccountOpportunityPageFiltered from '@salesforce/apex/OpportunityReportPerAccountController.getAccountOpportunityPageFiltered';

export default class OpportunityReportPerAccountComponent extends LightningElement {
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

    retrieveAndUpdate() {
        if (!this.searchContext.accountName && !this.searchContext.priceFrom && !this.searchContext.priceTo) {
            getAccountOpportunityPage({
                pageN: this.currentPage,
            }).then(result => {
                let data = JSON.parse(result);
                this.accountsList = data.accounts;
                this.pagesAmount = data.pagesAmount;
                this.isPaginationShown = (this.pagesAmount) > 1;
            }).catch(error => {
                console.log(error);
            });
        } else {
            getAccountOpportunityPageFiltered({
                pageN: this.currentPage,
                searchTokens: this.searchContext.accountName,
                min: this.searchContext.priceFrom,
                max: this.searchContext.priceTo
            }).then(result => {
                let data = JSON.parse(result);
                this.accountsList = data.accounts;
                this.pagesAmount = data.pagesAmount;
                this.isPaginationShown = (this.pagesAmount) > 1;
            }).catch(error => {
                console.log(error);
            });
        }
    }

    connectedCallback() {
        // Initial data retrieve
        getAccountOpportunityPage({
            pageN: 1,
        }).then(result => {
            let data = JSON.parse(result);
            this.accountsList = data.accounts;
            this.pagesAmount = data.pagesAmount;
            this.isPaginationShown = (this.pagesAmount) > 1;
        }).catch(error => {
            console.log(error);
        });
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
        clearTimeout(this.searchTimeout);
        this.searchContext.accountName = event.target.value.trim();

        this.searchTimeout = setTimeout(() => {
            if (event.target.value !== this.searchContext.accountName) {
                this.currentPage = 1;
                this.retrieveAndUpdate();
            }
        }, 1500);
    }

    handleTotalPriceFromChange(event) {
        clearTimeout(this.searchTimeout);
        this.searchContext.priceFrom = parseInt(event.target.value.trim());

        this.searchTimeout = setTimeout(() => {
            this.currentPage = 1;
            this.retrieveAndUpdate();
        }, 1500);
    }

    handleTotalPriceToChange(event) {
        clearTimeout(this.searchTimeout);
        this.searchContext.priceTo = parseInt(event.target.value.trim());

        this.searchTimeout = setTimeout(() => {
            this.currentPage = 1;
            this.retrieveAndUpdate();
        }, 1500);
    }

    openModal(event) {
        let title = event.target.dataset.title;

        getProductsDataByOppId({
            oppId: event.target.dataset.id
        }).then(data => {
            let products = JSON.parse(data);
            this.modalContext.title = title;
            this.modalContext.empty = (products.length < 1);
            this.modalContext.products = products;
            this.isModalOpen = true;
        }).catch(error => {
            console.log(error);
        });
    }

    closeModal(event) {
        this.isModalOpen = false;
    }
}