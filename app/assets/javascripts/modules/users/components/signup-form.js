import BaseComponent from '~/base/component';

const PASSWORD_FIELD = '#user_password';
const USERNAME_FIELD = '#user_username';
const EMAIL_FIELD = '#user_email';
const CONFIRMATION_PASSWORD_FIELD = '#user_password_confirmation';
const SUBMIT_BUTTON = '#submit_btn';

// UsersPasswordForm component that handles user password form
// interactions.
class UsersSignUpForm extends BaseComponent {
  elements() {
    this.$password = this.$el.find(PASSWORD_FIELD);
    this.$passwordConfirmation = this.$el.find(CONFIRMATION_PASSWORD_FIELD);
    this.$username = this.$el.find(USERNAME_FIELD);
    this.$userEmail = this.$el.find(EMAIL_FIELD);
    this.$submit = this.$el.find(SUBMIT_BUTTON);
  }

  events() {
    this.$el.on('focusout', PASSWORD_FIELD, e => this.onFocusout(e));
    this.$el.on('focusout', CONFIRMATION_PASSWORD_FIELD, e => this.onFocusout(e));
    this.$el.on('focusout', USERNAME_FIELD, e => this.onFocusout(e));
    this.$el.on('focusout', EMAIL_FIELD, e => this.onFocusout(e));
  }

  onFocusout() {
    const usernameInvalid = !this.$username[0].validity.valid;
    const emailInvalid = !this.$userEmail[0].validity.valid;
    const passwordInvalid = !this.$password.val() || this.$password.val().length < 8;
    const passwordConfirmationInvalid = !this.$passwordConfirmation.val() ||
      this.$password.val() !== this.$passwordConfirmation.val();

    if (passwordConfirmationInvalid) {
      this.$passwordConfirmation[0].setCustomValidity('Please enter same password as above');
    } else {
      this.$passwordConfirmation[0].setCustomValidity('');
    }

    if (passwordInvalid) {
      this.$password[0].setCustomValidity('Password should be of at least 8 characters minimum.');
    } else {
      this.$password[0].setCustomValidity('');
      this.$passwordConfirmation.attr('pattern', this.$password.val());
    }

    if (passwordInvalid || passwordConfirmationInvalid || emailInvalid || usernameInvalid) {
      this.$submit.attr('disabled', true);
    } else {
      this.$submit.removeAttr('disabled');
    }
  }
}

export default UsersSignUpForm;
