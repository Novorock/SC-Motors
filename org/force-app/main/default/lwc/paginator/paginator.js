import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {
    _currentPage = 1;
    _totalAmount = 3;
    previousDisabled = false;
    nextDisabled = false;

    updatePaginatorStatus(value) {
        if (this._totalAmount < 2) {
            this.previousDisabled = true;
            this.nextDisabled = true;
        } else if (value == this._totalAmount) {
            this.nextDisabled = true;
            this.previousDisabled = false;
        } else if (value == 1) {
            this.previousDisabled = true;
            this.nextDisabled = false;
        } else {
            this.nextDisabled = false;
            this.previousDisabled = false;
        }

        this._currentPage = value;
    }

    @api get pagesTotalAmount() {
        return this._totalAmount;
    }

    set pagesTotalAmount(value) {
        this._totalAmount = value;
        this.updatePaginatorStatus(1);
    }

    @api get currentPage() {
        return this._currentPage;
    }

    set currentPage(value) {
        this.updatePaginatorStatus(value);
    }

    previousPage(event) {
        event.target?.blur();
        
        if (this._currentPage - 1 >= 1) {
            console.log("Generate 'newpage' event.");
            this.dispatchEvent(new CustomEvent("newpage", {
                bubbles: true,
                detail: { page: this._currentPage - 1 }
            }));
            this.updatePaginatorStatus(this._currentPage - 1);
        }
    }

    nextPage(event) {
        event.target?.blur();

        if (this._currentPage + 1 <= this._totalAmount) {
            console.log("Generate 'newpage' event.");
            this.dispatchEvent(new CustomEvent("newpage", {
                bubbles: true,
                detail: { page: this._currentPage + 1 }
            }));

            this.updatePaginatorStatus(this._currentPage + 1);
        }
    }
}