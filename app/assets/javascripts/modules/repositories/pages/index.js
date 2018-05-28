import Vue from 'vue';

import RepositoriesPanel from '../components/panel';

$(() => {
  if (!$('body[data-route="repositories/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="repositories/index"] .vue-root',

    components: {
      RepositoriesPanel,
    },

    data() {
      return {
        repositories: window.repositories,
        teamRepositoriesNames: window.teamRepositoriesNames,
      };
    },

    computed: {
      teamRepositories() {
        // eslint-disable-next-line
        return this.repositories.filter((r) => {
          return this.teamRepositoriesNames.indexOf(r.full_name) !== -1;
        });
      },

      otherRepositories() {
        // eslint-disable-next-line
        return this.repositories.filter((r) => {
          return this.teamRepositoriesNames.indexOf(r.full_name) === -1;
        });
      },
    },
  });
});
