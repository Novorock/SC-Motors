import { LightningElement } from 'lwc';

export default class AccountQuickFind extends LightningElement {
    accountName = null;
    totalPrice = null;
    currentValue = null;
    timeout = 0;

    handleChange(event) {
        let val = event.target.value.trim();

        clearTimeout(this.timeout);

        this.timeout = setTimeout(() => {
            let tokens = val.split(' ');

            if (tokens.length > 1) {
                let last = tokens.pop();
                let found = last.match(/\d+/g);

                if (found.length > 0) {
                    this.totalPrice = last;
                } else {
                    tokens.push(last);
                    this.totalPrice = null;
                }

                this.accountName = tokens.join(' ');
            } else {
                if (tokens[0].match(/\d+/g)) {
                    this.totalPrice = tokens[0];
                    this.accountName = null;
                } else {
                    this.totalPrice = null;
                    this.accountName = tokens[0];
                }
            }

            this.dispatchEvent(new CustomEvent("quickfind", {
                bubbles: true,
                detail: {name: this.accountName, price: this.totalPrice}
            }));
        }, 500);
    }
}