import getProperty from 'lodash/get';

import Comparator from '~/utils/comparator';

import TableSortableMixin from '~/shared/mixins/table-sortable';
import TablePaginatedMixin from '~/shared/mixins/table-paginated';
import MembersPermissions from '../../mixins/members-permissions';

import TeamMembersTableRow from './table-row';

export default {
  template: '#js-team-members-table-tmpl',

  props: {
    members: {
      type: Array,
    },
    prefix: {
      type: String,
      default: 'tm_',
    },
  },

  mixins: [
    TableSortableMixin,
    TablePaginatedMixin,
    MembersPermissions,
  ],

  components: {
    TeamMembersTableRow,
  },

  computed: {
    filteredMembers() {
      const order = this.sorting.asc ? 1 : -1;
      const sortedMembers = [...this.members];
      const sample = sortedMembers[0];
      const value = getProperty(sample, this.sorting.by);
      const comparator = Comparator.of(value);

      // sorting
      sortedMembers.sort((a, b) => {
        const aValue = getProperty(a, this.sorting.by);
        const bValue = getProperty(b, this.sorting.by);

        return order * comparator(aValue, bValue);
      });

      // pagination
      const slicedMembers = sortedMembers.slice(this.offset, this.limit * this.currentPage);

      return slicedMembers;
    },
  },
};
