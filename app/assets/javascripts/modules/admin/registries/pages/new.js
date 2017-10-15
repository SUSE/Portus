import Vue from 'vue';

import RegistryForm from '../components/form';

$(() => {
  if (!$('body[data-route="admin/registries/new"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="admin/registries/new"] .vue-root',

    components: {
      RegistryForm,
    },
  });
});
