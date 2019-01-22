<template>
  <div>
    <table class="table table-striped table-hover" :class="{'table-sortable': sortable}">
      <colgroup>
        <col class="col-5">
        <col class="col-30">
        <col class="col-25">
        <col class="col-20">
        <col class="col-20">
      </colgroup>
      <thead>
        <tr>
          <th></th>
          <th @click="sort('name')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'name' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'name' && !sorting.asc,
            }"></i>
            Team
          </th>
          <th @click="sort('role')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'role' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'role' && !sorting.asc,
            }"></i>
            Role
          </th>
          <th>Members</th>
          <th>Namespaces</th>
        </tr>
      </thead>
      <tbody>
        <team-table-row v-for="team in filteredTeams" :key="team.id" :team="team" :teams-path="teamsPath"></team-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="teams.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import getProperty from 'lodash/get';

  import Comparator from '~/utils/comparator';

  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import TeamTableRow from './table-row';

  export default {
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
        const slicedTeams = sortedTeams.slice(this.offset, this.perPage * this.currentPage);

        return slicedTeams;
      },
    },
  };
</script>
