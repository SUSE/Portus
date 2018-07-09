import Vue from 'vue';

import AdminRegistriesNewPage from './pages/new';
import AdminRegistriesEditPage from './pages/edit';

$(() => {
  if (!$('body[data-controller="admin/registries"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      AdminRegistriesNewPage,
      AdminRegistriesEditPage,
    },
  });
});
