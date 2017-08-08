import moment from 'moment';

import NamespaceVisibility from './visibility';

export default {
  template: '#js-namespace-table-row-tmpl',

  props: ['namespace'],

  computed: {
    scopeClass() {
      return `namespace_${this.namespace.id}`;
    },

    createdAt() {
      return moment(this.namespace.attributes.created_at).format('MMMM DD, YYYY HH:mm');
    },
  },

  components: {
    NamespaceVisibility,
  },
};
