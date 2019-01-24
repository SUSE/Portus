<template>
  <tr :class="scopeClass">
    <td v-if="isCurrentUser">{{ user.username }}</td>
    <td v-else>
      <a :href="editUserPath">{{ user.username }}</a>
    </td>
    <td>{{ user.email }}</td>
    <td>
      <a class="btn btn-default toggle-user-admin-btn"
        role="button"
        :disabled="isCurrentUser"
        @click="toggleAdmin">
        <i class="fa fa-lg" :class="adminClass"></i>
      </a>
    </td>
    <td>{{ user.namespaces_count }}</td>
    <td>{{ user.teams_count }}</td>
    <td>
      <a class="btn btn-default toggle-user-enabled-btn"
        role="button"
        :disabled="singleAdmin && isCurrentUser"
        @click="toggleEnabled">
        <i class="fa fa-lg" :class="enabledClass"></i>
      </a>
    </td>
    <td>{{ isBot }}</td>
    <td>
      <a class="btn btn-default delete-user-btn"
        data-placement="left"
        data-toggle="popover"
        data-title="Please confirm"
        data-content="<p>Are you sure you want to remove this user?</p><a class='btn btn-default'>No</a> <a class='btn btn-primary yes' rel='nofollow'>Yes</a>"
        data-html="true"
        tabindex="0"
        role="button"
        :disabled="isCurrentUser">
        <i class="fa fa-trash fa-lg"></i>
      </a>
    </td>
  </tr>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

  import UsersStore from '../store';

  import UsersService from '../service';

  const { state } = UsersStore;
  const { set } = Vue;

  export default {
    props: ['user', 'usersPath'],

    methods: {
      toggleAdmin() {
        UsersService.toggleAdmin(this.user).then(() => {
          set(this.user, 'admin', !this.user.admin);

          if (this.user.admin) {
            this.$alert.$show(`User '${this.user.username}' is now an admin`);
          } else {
            this.$alert.$show(`User '${this.user.username}' is no longer an admin`);
          }
        }).catch(handleHttpResponseError);
      },

      toggleEnabled() {
        UsersService.toggleEnabled(this.user).then((response) => {
          set(this.user, 'enabled', !this.user.enabled);

          if (this.user.enabled) {
            this.$alert.$show(`User '${this.user.username}' has been enabled`);
          } else {
            this.$alert.$show(`User '${this.user.username}' has been disabled`);
          }

          if (response.data.redirect) {
            window.location.reload(false);
          }
        }).catch(handleHttpResponseError);
      },

      destroy() {
        UsersService.destroy(this.user).then(() => {
          this.$bus.$emit('userDestroyed', this.user);
          this.$alert.$show(`User '${this.user.username}' was removed successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    computed: {
      scopeClass() {
        return `user_${this.user.id}`;
      },

      isBot() {
        if (this.user.bot) {
          return 'Yes';
        }

        return 'No';
      },

      enabledClass() {
        if (this.user.enabled) {
          return 'fa-toggle-on';
        }

        return 'fa-toggle-off';
      },

      adminClass() {
        if (this.user.admin) {
          return 'fa-toggle-on';
        }

        return 'fa-toggle-off';
      },

      isCurrentUser() {
        return state.currentUserId === this.user.id;
      },

      singleAdmin() {
        return state.singleAdmin;
      },

      editUserPath() {
        return `${this.usersPath}/${this.user.id}/edit`;
      },
    },

    mounted() {
      const REMOVE_BTN = '.delete-user-btn';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', REMOVE_BTN, () => {
        const $yes = $(this.$el).find(REMOVE_BTN).next().find('.yes');
        $yes.click(this.destroy.bind(this));
      });
    },
  };
</script>
