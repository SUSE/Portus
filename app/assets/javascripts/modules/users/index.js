import Vue from 'vue';

import AppTokensWrapper from './components/application-tokens/wrapper';
import DisableAccountPanel from './components/disable-account-panel';

import UsersIndexPage from './pages/index';
import UsersEditPage from './pages/edit';

const USERS_SELF_EDIT_ROUTE = 'auth/registrations/edit';

$(() => {
  const $body = $('body');
  const route = $body.data('route');
  const controller = $body.data('controller');

  if (controller === 'admin/users' || route === USERS_SELF_EDIT_ROUTE) {
    // eslint-disable-next-line no-new
    new Vue({
      el: '.vue-root',

      components: {
        AppTokensWrapper,
        DisableAccountPanel,
        UsersIndexPage,
      },

      mounted() {
        // eslint-disable-next-line
        new UsersEditPage($body);
      },
    });
  }
});
