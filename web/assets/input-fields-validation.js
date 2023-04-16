const form = document.getElementById('web_to_lead');
const company = document.getElementById('company');
const first_name = document.getElementById('first_name');
const last_name = document.getElementById('last_name');
const email = document.getElementById('email');
const phone = document.getElementById('phone');

function setError(element, text) {
    let error = element.parentElement.querySelector('.error');
    error.innerText = text;
    element.classList.add('error-field');
}

function unsetError(element) {
    let error = element.parentElement.querySelector('.error');
    error.innerText = '';
    element.classList.remove('error-field');
}

function isEmailValid(email) {
    const re = /^(([^<>()[\]\\.,;:\s@']+(\.[^<>()[\]\\.,;:\s@']+)*)|('.+'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    return re.test(String(email).toLowerCase());
}

function isPhoneValid(phone) {
    const re = /^\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})$/;

    return re.test(phone.toLowerCase());
}

form.addEventListener('submit', event => {
    let company_value = company.value.trim();
    let first_name_value = first_name.value.trim();
    let last_name_value = last_name.value.trim();
    let email_value = email.value.trim();
    let phone_value = phone.value.trim();
    let rollback = false;

    if (company_value === '') {
        setError(company, 'Company name is required.');
        rollback = true;
    } else {
        unsetError(company);
    }

    if (first_name_value === '') {
        setError(first_name, 'First name is required.');
        rollback = true;
    } else {
        unsetError(first_name);
    }

    if (last_name_value === '') {
        setError(last_name, 'Last name is required.');
        rollback = true;
    } else {
        unsetError(last_name);
    }

    if (email_value === '') {
        setError(email, 'Email is required.');
        rollback = true;
    } else if (!isEmailValid(email_value)) {
        setError(email, 'Email is not valid.')
        rollback = true;
    } else {
        unsetError(email);
    }

    if (phone_value === '') {
        setError(phone, 'Phone is required.');
        rollback = true;
    } else if (!isPhoneValid(phone_value)) {
        setError(phone, 'Phone is not valid. Example: (173)543-2381.')
        rollback = true;
    } else {
        unsetError(phone);
    }

    if (rollback) {
        event.preventDefault();
    }
});
