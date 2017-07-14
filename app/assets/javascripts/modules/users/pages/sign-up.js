import BaseComponent from '~/base/component';

import { fadeIn } from '~/utils/effects';
import SignUpForm from '../components/signup-form';

const SIGN_UP_FORM = 'form.new_user';

// UsersSignUpPage component responsible to instantiate
// the user's sign up page components and handle interactions.
class UsersSignUpPage extends BaseComponent {
  elements() {
    this.$signupForm = this.$el.find(SIGN_UP_FORM);
  }

  mount() {
    fadeIn(this.$el);
    this.signupForm = new SignUpForm(this.$signupForm);
  }
}

export default UsersSignUpPage;
