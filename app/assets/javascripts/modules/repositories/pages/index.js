import Vue from 'vue';

import RepositoriesTable from '../components/table';

$(() => {
  if (!$('body[data-route="repositories/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="repositories/index"] .vue-root',

    components: {
      RepositoriesTable,
    },

    data() {
      return {
        repositories: window.repositories,
      };
    },
  });
});
