import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'
import getDataByPage from '@salesforce/apex/LwcAccountController.getDataByPage';
import getDataById from '@salesforce/apex/LwcAccountController.getDataById';
import getPagesTotalAmount from '@salesforce/apex/LwcAccountController.getPagesTotalAmount';
import getProductsByOppId from '@salesforce/apex/LwcAccountController.getProductsByOppId';

export default class LwcAccountComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    isRecordPage = false;

    accountData = [];
    isEmptyList = false;

    paginationContext = {
        pagesTotalAmount: 1,
        currentPage: 1,
        previousDisabled: false,
        nextDisabled: false
    };

    isModalOpen = false;
    modalContext = {
        title: null,
        items: [],
        empty: true
    };

    quickFindContext = {
        accountName: null,
        totalPrice: null,
        currentValue: null
    };

    findTimeout = 0;

    retrieveAndUpdate(pageNumber) {
        var component = this;

        console.log(component.quickFindContext.accountName);

        getPagesTotalAmount({
            key: component.quickFindContext.accountName,
            totalPrice: component.quickFindContext.totalPrice
        }).then(pagesAmount => {
            component.paginationContext.pagesTotalAmount = JSON.parse(pagesAmount);

            getDataByPage({
                p: pageNumber,
                key: component.quickFindContext.accountName,
                totalPrice: component.quickFindContext.totalPrice
            }).then(result => {
                component.accountData = JSON.parse(result);

                for (let i = 0; i < component.accountData.length; i++) {
                    let item = component.accountData[i];
                    item.Title = `${item.Name} (${item.Total} €)`;
                }

                if (component.accountData.length < 1) {
                    component.isEmptyList = true;
                } else {
                    component.isEmptyList = false;
                }

                if (pagesAmount < 2) {
                    component.paginationContext.previousDisabled = true;
                    component.paginationContext.nextDisabled = true;
                } else if (pageNumber == pagesAmount) {
                    component.paginationContext.nextDisabled = true;
                    component.paginationContext.previousDisabled = false;
                } else if (pageNumber == 1) {
                    component.paginationContext.previousDisabled = true;
                    component.paginationContext.nextDisabled = false;
                } else {
                    component.paginationContext.nextDisabled = false;
                    component.paginationContext.previousDisabled = false;
                }

                component.paginationContext.currentPage = pageNumber;
            }).catch(error => {
                console.log(error);
            });
        }).catch(error => {
            console.log(error);
        });
    }

    connectedCallback() {
        var component = this;

        if (!component.recordId) {
            component.retrieveAndUpdate(1);
        } else {
            component.isRecordPage = true;

            getDataById({
                id: component.recordId
            }).then(result => {
                component.accountData = JSON.parse(result)[0];
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

    handleQuickFind(event) {
        var component = this;
        let val = event.target.value.trim();

        clearTimeout(component.findTimeout);

        component.findTimeout = setTimeout(() => {
            let tokens = val.split(' ');

            if (tokens.length > 1) {
                let last = tokens.pop();
                let found = last.match(/\d+/g);

                if (found.length > 0) {
                    component.quickFindContext.totalPrice = last;
                } else {
                    tokens.push(last);
                    component.quickFindContext.totalPrice = null;
                }

                component.quickFindContext.accountName = tokens.join(' ');
            } else {
                if (tokens[0].match(/\d+/g)) {
                    component.quickFindContext.totalPrice = tokens[0];
                    component.quickFindContext.accountName = null;
                } else {
                    component.quickFindContext.totalPrice = null;
                    component.quickFindContext.accountName = tokens[0];
                }
            }

            component.retrieveAndUpdate(1);
        }, 1000);
    }

    handleOpenModal(event) {
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

    handleCloseModal(event) {
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