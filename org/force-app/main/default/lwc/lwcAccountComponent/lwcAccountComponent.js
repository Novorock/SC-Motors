import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import getAccountOpportunityPage from '@salesforce/apex/LwcAccountController.getAccountOpportunityPage';
import getProductsByOppId from '@salesforce/apex/LwcAccountController.getProductsByOppId';
import getAccountOpportunityPageFiltered from '@salesforce/apex/LwcAccountController.getAccountOpportunityPageFiltered';
import getAccountOpportunityById from '@salesforce/apex/LwcAccountController.getAccountOpportunityById';

export default class LwcAccountComponent extends NavigationMixin(LightningElement) {
    // Record Page Stuff
    @api recordId;
    isRecordPage = false;
    currentRecord = {};

    // Custom Lightning Tab Stuff 
    accountsList = [];
    isEmptyList = false;

    paginationContext = {
        pagesAmount: 1,
        currentPage: 1,
        previousDisabled: false,
        nextDisabled: false
    };

    isModalOpen = false;
    modalContext = {
        title: '',
        items: [],
        empty: true
    };

    searchContext = {
        accountName: '',
        priceFrom: 0,
        priceTo: 0
    };

    searchTimeout = 0;

    update(data, pageNumber) {
        var component = this;

        component.accountsList = data.Accounts;
        component.paginationContext.pagesAmount = data.PagesAmount;

        if (component.paginationContext.pagesAmount < 2) {
            component.paginationContext.previousDisabled = true;
            component.paginationContext.nextDisabled = true;
        } else if (pageNumber == component.paginationContext.pagesAmount) {
            component.paginationContext.nextDisabled = true;
            component.paginationContext.previousDisabled = false;
        } else if (pageNumber == 1) {
            component.paginationContext.previousDisabled = true;
            component.paginationContext.nextDisabled = false;
        } else {
            component.paginationContext.previousDisabled = false;
            component.paginationContext.nextDisabled = false;
        }

        component.paginationContext.currentPage = pageNumber;

        if (component.accountsList.length < 1) {
            component.isEmptyList = true;
        } else {
            component.isEmptyList = false;
        }
    }

    retrieveAndUpdate(pageNumber) {
        var component = this;

        if (!component.searchContext.accountName && !component.searchContext.priceFrom && !component.searchContext.priceTo) {
            getAccountOpportunityPage({
                pageN: pageNumber
            }).then(result => {
                component.update(JSON.parse(result), pageNumber);
            }).catch(error => {
                console.log(error);
            });
        } else {
            getAccountOpportunityPageFiltered({
                pageN: pageNumber,
                searchTokens: component.searchContext.accountName,
                min: component.searchContext.priceFrom,
                max: component.searchContext.priceTo
            }).then(result => {
                component.update(JSON.parse(result), pageNumber);
            }).catch(error => {
                console.log(error);
            });
        }
    }

    connectedCallback() {
        var component = this;

        // Initial data retrieve
        if (!component.recordId) {
            component.retrieveAndUpdate(1);
        } else {
            component.isRecordPage = true;

            getAccountOpportunityById({
                id: component.recordId
            }).then(result => {
                component.currentRecord = JSON.parse(result).Accounts[0];
            }).catch(error => {
                console.log(error);
            });
        }
    }

    handleNextPage(event) {
        this.retrieveAndUpdate(this.paginationContext.currentPage + 1);
    }

    handlePreviousPage(event) {
        this.retrieveAndUpdate(this.paginationContext.currentPage - 1);
    }

    handleAccountNameChange(event) {
        var component = this;

        clearTimeout(component.searchTimeout);
        component.searchContext.accountName = event.target.value.trim();

        component.searchTimeout = setTimeout(() => {
            if (event.target.value !== component.searchContext.accountName) {
                component.retrieveAndUpdate(1);
            }
        }, 1000);
    }

    handleTotalPriceFromChange(event) {
        var component = this;

        clearTimeout(component.searchTimeout);
        component.searchContext.priceFrom = parseInt(event.target.value.trim());

        component.searchTimeout = setTimeout(() => {
            component.retrieveAndUpdate(1);
        }, 1000);
    }

    handleTotalPriceToChange(event) {
        var component = this;

        clearTimeout(component.searchTimeout);
        component.searchContext.priceTo = parseInt(event.target.value.trim());
        component.searchTimeout = setTimeout(() => {
            component.retrieveAndUpdate(1);
        }, 1000);
    }

    openModal(event) {
        var component = this;

        let title = event.target.dataset.title;

        getProductsByOppId({
            oppId: event.target.dataset.id
        }).then(data => {
            let products = JSON.parse(data);
            component.modalContext.title = title;
            component.modalContext.empty = (products.length < 1);
            component.modalContext.items = products;
            component.isModalOpen = true;
        }).catch(error => {
            console.log(error);
        });
    }

    closeModal(event) {
        this.isModalOpen = false;
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