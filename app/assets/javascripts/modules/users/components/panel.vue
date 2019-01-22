<template>
  <panel>
    <h5 slot="heading-left">Users</h5>

    <toggle-link slot="heading-right" text="Create" :state="state" state-key="newFormVisible" class="toggle-link-new-user"></toggle-link>

    <div slot="body">
      <users-table :users="users" :sortable="true" sort-by="username" :users-path="usersPath"></users-table>
    </div>
  </panel>
</template>

<script>
  import UsersTable from './table';

  export default {
    props: {
      users: Array,
      usersPath: String,
      state: Object,
    },

    components: {
      UsersTable,
    },
  };
</script>
