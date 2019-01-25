import BaseComponent from '~/base/component';

import ProfileForm from '../../components/profile-form';
import PasswordForm from '../../components/password-form';

const PROFILE_FORM = 'form.profile';
const PASSWORD_FORM = 'form.password';

// UsersEditPage component responsible to instantiate
// the user's edit page components and handle interactions.
class UsersEditPage extends BaseComponent {
  elements() {
    this.$profileForm = this.$el.find(PROFILE_FORM);
    this.$passwordForm = this.$el.find(PASSWORD_FORM);
  }

  mount() {
    this.profileForm = new ProfileForm(this.$profileForm);
    this.passwordForm = new PasswordForm(this.$passwordForm);
  }
}

export default UsersEditPage;
