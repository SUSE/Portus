<template>
  <div>
    <table class="table table-striped table-hover" :class="{'table-sortable': sortable}">
      <colgroup>
        <col class="col-20">
        <col class="col-20">
        <col class="col-10">
        <col class="col-10">
        <col class="col-10">
        <col class="col-10">
        <col class="col-10">
        <col class="col-10">
      </colgroup>
      <thead>
        <tr>
          <th @click="sort('username')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'username' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'username' && !sorting.asc,
            }"></i>
            Name
          </th>
          <th @click="sort('email')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'email' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'email' && !sorting.asc,
            }"></i>
            Email
          </th>
          <th @click="sort('admin')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'admin' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'admin' && !sorting.asc,
            }"></i>
            Admin
          </th>
          <th>Namespaces</th>
          <th>Teams</th>
          <th @click="sort('enabled')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'enabled' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'enabled' && !sorting.asc,
            }"></i>
            Enabled
          </th>
          <th @click="sort('bot')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'bot' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'bot' && !sorting.asc,
            }"></i>
            Bot
          </th>
          <th>Remove</th>
        </tr>
      </thead>
      <tbody>
        <user-table-row v-for="user in filteredUsers" :key="user.id" :user="user" :users-path="usersPath"></user-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="users.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import getProperty from 'lodash/get';

  import Comparator from '~/utils/comparator';

  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import UserTableRow from './table-row';

  export default {
    props: {
      users: Array,
      usersPath: String,
    },

    mixins: [TableSortableMixin, TablePaginatedMixin],

    components: {
      UserTableRow,
    },

    computed: {
      filteredUsers() {
        const order = this.sorting.asc ? 1 : -1;
        const sortedUsers = [...this.users];
        const sample = sortedUsers[0];
        const value = getProperty(sample, this.sorting.by);
        const comparator = Comparator.of(value);

        // sorting
        sortedUsers.sort((a, b) => {
          const aValue = getProperty(a, this.sorting.by);
          const bValue = getProperty(b, this.sorting.by);

          return order * comparator(aValue, bValue);
        });

        // pagination
        const slicedUsers = sortedUsers.slice(this.offset, this.perPage * this.currentPage);

        return slicedUsers;
      },
    },
  };
</script>
