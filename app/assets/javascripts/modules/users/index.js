import Vue from 'vue';

import DisableAccountPanel from './components/disable-account-panel';
import AppTokensWrapper from './components/application-tokens/wrapper';

import UsersIndexPage from './pages/index';
import UsersEditPage from './pages/edit';
import LegacyUsersEditPage from './pages/legacy/edit';

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
        UsersEditPage,
        UsersIndexPage,
      },

      mounted() {
        // eslint-disable-next-line
        new LegacyUsersEditPage($body);
      },
    });
  }
});
