import getProperty from 'lodash/get';

import Comparator from '~/utils/comparator';

import TableSortableMixin from '~/shared/mixins/table-sortable';
import TablePaginatedMixin from '~/shared/mixins/table-paginated';

import TeamTableRow from './table-row';

export default {
  template: '#js-teams-table-tmpl',

  props: {
    teams: {
      type: Array,
    },
    teamsPath: {
      type: String,
    },
    prefix: {
      type: String,
      default: 'tm_',
    },
  },

  mixins: [TableSortableMixin, TablePaginatedMixin],

  components: {
    TeamTableRow,
  },

  computed: {
    filteredTeams() {
      const order = this.sorting.asc ? 1 : -1;
      const sortedTeams = [...this.teams];
      const sample = sortedTeams[0];
      const value = getProperty(sample, this.sorting.by);
      const comparator = Comparator.of(value);

      // sorting
      sortedTeams.sort((a, b) => {
        const aValue = getProperty(a, this.sorting.by);
        const bValue = getProperty(b, this.sorting.by);

        return order * comparator(aValue, bValue);
      });

      // pagination
      const slicedTeams = sortedTeams.slice(this.offset, this.limit * this.currentPage);

      return slicedTeams;
    },
  },
};
