import Vue from 'vue';

import RegistryForm from '../components/form';

$(() => {
  if (!$('body[data-route="admin/registries/edit"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="admin/registries/edit"] .vue-root',

    components: {
      RegistryForm,
    },
  });
});
