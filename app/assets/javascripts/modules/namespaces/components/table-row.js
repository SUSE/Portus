import moment from 'moment';

import NamespaceVisibility from './visibility';

export default {
  template: '#js-namespace-table-row-tmpl',

  props: ['namespace', 'namespacesPath', 'webhooksPath'],

  computed: {
    scopeClass() {
      return `namespace_${this.namespace.id}`;
    },

    repositoryUrl() {
      return `${this.namespacesPath}/${this.namespace.id}`;
    },

    webhooksUrl() {
      return `${this.repositoryUrl}/${this.webhooksPath}`;
    },

    createdAt() {
      return moment(this.namespace.created_at).format('MMMM DD, YYYY HH:mm');
    },
  },

  components: {
    NamespaceVisibility,
  },
};
