import getProperty from 'lodash/get';

import Comparator from '~/utils/comparator';

import TableSortableMixin from '~/shared/mixins/table-sortable';
import TablePaginatedMixin from '~/shared/mixins/table-paginated';

import NamespaceTableRow from './table-row';

export default {
  template: '#js-namespaces-table-tmpl',

  props: {
    namespaces: {
      type: Array,
    },
    prefix: {
      type: String,
      default: 'ns_',
    },
  },

  mixins: [TableSortableMixin, TablePaginatedMixin],

  components: {
    NamespaceTableRow,
  },

  computed: {
    filteredNamespaces() {
      const order = this.sorting.asc ? 1 : -1;
      const sortedNamespaces = [...this.namespaces];
      const sample = sortedNamespaces[0];
      const value = getProperty(sample, this.sorting.by);
      const comparator = Comparator.of(value);

      // sorting
      sortedNamespaces.sort((a, b) => {
        const aValue = getProperty(a, this.sorting.by);
        const bValue = getProperty(b, this.sorting.by);

        return order * comparator(aValue, bValue);
      });

      // pagination
      const slicedNamespaces = sortedNamespaces.slice(this.offset, this.limit * this.currentPage);

      return slicedNamespaces;
    },
  },
};
