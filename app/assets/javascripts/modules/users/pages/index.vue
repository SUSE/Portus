<template>
  <div class="teams-index-page">
    <new-user-form :state="state" form-state="newFormVisible"></new-user-form>
    <users-panel :users="users" :users-path="usersPath" :state="state"></users-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import NewUserForm from '../components/new-form';
  import UsersPanel from '../components/panel';

  import UsersStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      usersRef: Array,
      usersPath: String,
      currentUserId: Number,
      adminCount: Number,
    },

    components: {
      UsersPanel,
      NewUserForm,
    },

    data() {
      return {
        state: UsersStore.state,
        users: [...this.usersRef],
      };
    },

    methods: {
      onCreate(user) {
        const currentUsers = this.users;
        const users = [
          ...currentUsers,
          user,
        ];

        set(this, 'users', users);
      },

      onDestroy(user) {
        const currentUsers = this.users;
        const index = currentUsers.findIndex(t => t.id === user.id);

        const users = [
          ...currentUsers.slice(0, index),
          ...currentUsers.slice(index + 1),
        ];

        set(this, 'users', users);
      },
    },

    created() {
      set(this.state, 'currentUserId', this.currentUserId);
      set(this.state, 'singleAdmin', this.adminCount === 1);
    },

    mounted() {
      this.$bus.$on('userCreated', user => this.onCreate(user));
      this.$bus.$on('userDestroyed', user => this.onDestroy(user));
    },
  };
</script>
