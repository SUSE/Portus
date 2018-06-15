import Vue from 'vue';

import AppTokensWrapper from './components/application-tokens/wrapper';

import UsersEditPage from './pages/edit';
import UsersSignUpPage from './pages/sign-up';
import UsersSignInPage from './pages/sign-in';

const USERS_EDIT_ROUTE = 'auth/registrations/edit';
const USERS_SIGN_IN_ROUTE = 'auth/sessions/new';
const USERS_SIGN_UP_ROUTE = 'auth/registrations/new';

$(() => {
  const $body = $('body');
  const route = $body.data('route');

  if (route === USERS_SIGN_UP_ROUTE) {
     // eslint-disable-next-line
      new UsersSignUpPage($body);
  }

  if (route === USERS_SIGN_IN_ROUTE) {
     // eslint-disable-next-line
      new UsersSignInPage($body);
  }

  if (route === USERS_EDIT_ROUTE) {
    // eslint-disable-next-line no-new
    new Vue({
      el: '.vue-root',

      components: {
        AppTokensWrapper,
      },

      mounted() {
        // eslint-disable-next-line
        new UsersEditPage($body);
      },
    });
  }
});
