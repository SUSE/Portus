import Vue from 'vue';

import ToggleLink from '~/shared/components/toggle-link';

import NamespacesPanel from '../components/panel';
import NewNamespaceForm from '../components/new-form';

import NamespacesService from '../services/namespaces';

import NamespacesStore from '../store';

const { set } = Vue;

$(() => {
  if (!$('body[data-route="namespaces/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="namespaces/index"] .vue-root',

    components: {
      NewNamespaceForm,
      NamespacesPanel,
      ToggleLink,
    },

    data() {
      return {
        state: NamespacesStore.state,
        userNamespaceId: window.userNamespaceId,
        normalNamespaces: [],
        specialNamespaces: [],
      };
    },

    methods: {
      onCreate(namespace) {
        const currentNamespaces = this.normalNamespaces;
        const namespaces = [
          ...currentNamespaces,
          namespace,
        ];

        set(this, 'normalNamespaces', namespaces);
      },

      loadData() {
        NamespacesService.all().then((response) => {
          const namespaces = response.data;

          const normal = namespaces.filter(n => !n.global && n.id !== this.userNamespaceId);
          const special = namespaces.filter(n => n.global || n.id === this.userNamespaceId);

          set(this, 'normalNamespaces', normal);
          set(this, 'specialNamespaces', special);
          set(this.state, 'isLoading', false);
        });
      },
    },

    mounted() {
      set(this.state, 'isLoading', true);
      this.loadData();
      this.$bus.$on('namespaceCreated', namespace => this.onCreate(namespace));
    },
  });
});
