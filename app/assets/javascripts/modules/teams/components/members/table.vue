<template>
  <div>
    <table class="table table-striped table-hover" :class="{'table-sortable': sortable}">
      <colgroup v-if="canManage">
        <col class="col-5">
        <col class="col-40">
        <col class="col-35">
        <col class="col-10">
        <col class="col-10">
      </colgroup>
      <colgroup v-else>
        <col class="col-5">
        <col class="col-50">
        <col class="col-45">
      </colgroup>
      <thead>
        <tr>
          <th></th>
          <th @click="sort('display_name')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'display_name' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'display_name' && !sorting.asc,
            }"></i>
            User
          </th>
          <th @click="sort('role')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'role' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'role' && !sorting.asc,
            }"></i>
            Role
          </th>
          <th v-if="canManage">Edit</th>
          <th v-if="canManage">Remove</th>
        </tr>
      </thead>
      <tbody>
        <team-members-table-row v-for="member in filteredMembers" :key="member.id" :member="member" :can-manage="canManage"></team-members-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="members.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import getProperty from 'lodash/get';

  import Comparator from '~/utils/comparator';

  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import TeamMembersTableRow from './table-row';

  import TeamsStore from '../../store';

  export default {
    props: {
      members: {
        type: Array,
      },
      prefix: {
        type: String,
        default: 'tm_',
      },
      currentMember: {
        type: Object,
      },
    },

    mixins: [
      TableSortableMixin,
      TablePaginatedMixin,
    ],

    components: {
      TeamMembersTableRow,
    },

    data() {
      return {
        state: TeamsStore.state,
      };
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
        const slicedMembers = sortedMembers.slice(this.offset, this.perPage * this.currentPage);

        return slicedMembers;
      },

      canManage() {
        const enabledAndOwner = this.state.manageTeamsEnabled
                             && this.currentMember.role === 'owner';

        return this.currentMember.admin
            || enabledAndOwner;
      },
    },
  };
</script>
