import getProperty from 'lodash/get';

import Comparator from '~/utils/comparator';

import TableSortableMixin from '~/shared/mixins/table-sortable';
import TablePaginatedMixin from '~/shared/mixins/table-paginated';

import RepositoryTableRow from './table-row';

export default {
  template: '#js-repositories-table-tmpl',

  props: {
    repositories: {
      type: Array,
    },
    repositoriesPath: {
      type: String,
    },
    namespacesPath: {
      type: String,
    },
    prefix: {
      type: String,
      default: '',
    },
  },

  mixins: [TableSortableMixin, TablePaginatedMixin],

  components: {
    RepositoryTableRow,
  },

  computed: {
    filteredRepositories() {
      const order = this.sorting.asc ? 1 : -1;
      const sortedRepositories = [...this.repositories];
      const sample = sortedRepositories[0];
      const value = getProperty(sample, this.sorting.by);
      const comparator = Comparator.of(value);

      // sorting
      sortedRepositories.sort((a, b) => {
        const aValue = getProperty(a, this.sorting.by);
        const bValue = getProperty(b, this.sorting.by);

        return order * comparator(aValue, bValue);
      });

      // pagination
      const slicedTeams = sortedRepositories.slice(this.offset, this.limit * this.currentPage);

      return slicedTeams;
    },
  },
};
