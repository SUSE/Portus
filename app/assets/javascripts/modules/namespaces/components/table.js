import Vue from 'vue';
import getProperty from 'lodash/get';

import Comparator from '~/utils/comparator';
import TablePagination from '~/shared/components/table-pagination';

import NamespaceTableRow from './table-row';

const { set } = Vue;

export default {
  template: '#js-namespaces-table-tmpl',

  props: ['namespaces', 'sortable'],

  components: {
    NamespaceTableRow,
    TablePagination,
  },

  data() {
    return {
      sortAsc: true,
      sortBy: 'attributes.clean_name',
      limit: 3,
      currentPage: 1,
    };
  },

  computed: {
    offset() {
      return (this.currentPage - 1) * this.limit;
    },

    filteredNamespaces() {
      const order = this.sortAsc ? 1 : -1;
      const sortedNamespaces = [...this.namespaces];
      const sample = sortedNamespaces[0];
      const value = getProperty(sample, this.sortBy);
      const comparator = Comparator.of(value);

      // sorting
      sortedNamespaces.sort((a, b) => {
        const aValue = getProperty(a, this.sortBy);
        const bValue = getProperty(b, this.sortBy);

        return order * comparator(aValue, bValue);
      });

      // pagination
      const slicedNamespaces = sortedNamespaces.slice(this.offset, this.limit * this.currentPage);

      return slicedNamespaces;
    },
  },

  methods: {
    sort(attribute) {
      if (!this.sortable) {
        return;
      }

      // if sort column has changed, go always asc
      // inverse current order otherwise
      if (this.sortBy === attribute) {
        set(this, 'sortAsc', !this.sortAsc);
      } else {
        set(this, 'sortAsc', true);
      }

      set(this, 'sortBy', attribute);
    },
  },
};
