import Vue from 'vue';

import ToggleLink from '~/shared/components/toggle-link';
import EventBus from '~/utils/eventbus';

import NamespacesPanel from '../../namespaces/components/panel';
import NewNamespaceForm from '../../namespaces/components/new-form';

import NamespacesStore from '../../namespaces/store';

// legacy
import TeamDetails from '../components/team-details';
import TeamUsersPanel from '../components/team-users-panel';

const { set } = Vue;

$(() => {
  if (!$('body[data-route="teams/show"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="teams/show"] .vue-root',

    components: {
      NewNamespaceForm,
      NamespacesPanel,
      ToggleLink,
    },

    data() {
      return {
        namespaceState: NamespacesStore.state,
        namespaces: window.teamNamespaces.data,
      };
    },

    methods: {
      onCreate(namespace) {
        const currentNamespaces = this.namespaces;
        const namespaces = [
          ...currentNamespaces,
          namespace,
        ];

        set(this, 'namespaces', namespaces);
      },
    },

    mounted() {
      EventBus.$on('namespaceCreated', namespace => this.onCreate(namespace));

      // legacy
      const $teamDetails = $(this.$refs.details);
      const $teamUsersPanel = $(this.$refs.usersPanel);

      this.teamDetails = new TeamDetails($teamDetails);
      this.teamUsersPanel = new TeamUsersPanel($teamUsersPanel);
    },
  });
});
