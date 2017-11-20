import Vue from 'vue';

import ToggleLink from '~/shared/components/toggle-link';

import NamespaceInfo from '../components/info';
import EditNamespaceForm from '../components/edit-form';
import TeamLink from '../components/team-link';

import NamespacesStore from '../store';

const { set } = Vue;

$(() => {
  if (!$('body[data-route="namespaces/show"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="namespaces/show"] .vue-root',

    components: {
      NamespaceInfo,
      EditNamespaceForm,
      TeamLink,
      ToggleLink,
    },

    data() {
      return {
        state: NamespacesStore.state,
        namespace: window.namespace,
      };
    },

    methods: {
      onUpdate(namespace) {
        set(this.state, 'editFormVisible', false);
        set(this, 'namespace', namespace);
      },
    },

    mounted() {
      this.$bus.$on('namespaceUpdated', namespace => this.onUpdate(namespace));
    },
  });
});
