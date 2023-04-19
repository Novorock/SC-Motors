import { LightningElement } from 'lwc';
import getPagesAmount from '@salesforce/apex/OpportunityReportPerAccountController.getPagesAmount';
import getAccountOpportunityPage from '@salesforce/apex/OpportunityReportPerAccountController.getAccountOpportunityPage';
import getProductsDataByOppId from '@salesforce/apex/OpportunityReportPerAccountController.getProductsDataByOppId';

export default class OpportunityReportPerAccountComponent extends LightningElement {
    pagesAmount;
    currentPage = 1;
    data;

    isModalOpen = false;
    modalContext = {
        title: '',
        products: [],
        empty: true
    };


    connectedCallback() {
        // Initial data retrieve
        getPagesAmount({
            batchSize: 10
        }).then(amount => {
            this.pagesAmount = amount;
        }).catch(error => {
            console.log(error);
        });

        getAccountOpportunityPage({
            pageN: 1,
            batchSize: 10
        }).then(data => {
            this.data = JSON.parse(data);
        }).catch(error => {
            console.log(error);
        });
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