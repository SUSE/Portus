<template>
  <tr :class="scopeClass">
    <td class="table-icon">
      <i class="fa fa-lg" :class="memberIcon"></i>
    </td>
    <td>{{ member.display_name }}</td>
    <td>
      <div class="role" v-if="!editing">{{ role }}</div>
      <div v-if="editing">
        <form class="form-inline" @submit.prevent="update">
          <select class="form-control" :id="selectRoleId" v-model="selectedRole">
            <option v-for="r in availableRoles" :value="r.toLowerCase()" :key="r">{{ r }}</option>
          </select>
          <button class="btn btn-primary pull-right" type="submit">
            <i class="fa fa-check"></i> Save
          </button>
        </form>
      </div>

    <td v-if="canManage">
      <button class="btn btn-default edit-member-btn" @click.prevent="enterEditMode" v-if="!editing">
        <i class="fa fa-pencil fa-lg"></i>
      </button>
      <button class="btn btn-default edit-member-btn" @click.prevent="leaveEditMode" v-if="editing">
        <i class="fa fa-close fa-lg"></i>
      </button>
    </td>
    <td v-if="canManage">
      <a class="btn btn-default delete-team-user-btn"
        data-placement="left"
        data-toggle="popover"
        data-title="Please confirm"
        data-content="<p>Are you sure you want to remove this team member?</p><a class='btn btn-default'>No</a> <a class='btn btn-primary yes' rel='nofollow'>Yes</a>"
        data-html="true"
        tabindex="0"
        role="button">
        <i class="fa fa-trash fa-lg"></i>
      </a>
    </td>
  </tr>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

  import TeamsService from '../../service';
  import TeamsStore from '../../store';

  const { set } = Vue;

  export default {
    props: ['member', 'canManage'],

    data() {
      return {
        editing: false,
        selectedRole: this.member.role,
        availableRoles: TeamsStore.state.availableRoles,
      };
    },

    computed: {
      scopeClass() {
        return `team_member_${this.member.id}`;
      },

      selectRoleId() {
        return `select_role_${this.member.id}`;
      },

      role() {
        const firstChar = this.member.role.charAt(0);
        const restChars = this.member.role.slice(1);

        return firstChar.toUpperCase() + restChars;
      },

      memberIcon() {
        switch (this.member.role) {
          case 'owner':
            return 'fa-male';
          case 'contributor':
            return 'fa-exchange';
          // viewer
          default:
            return 'fa-eye';
        }
      },
    },

    methods: {
      enterEditMode() {
        set(this, 'editing', true);
      },

      leaveEditMode() {
        set(this, 'editing', false);
        set(this, 'selectedRole', this.member.role);
      },

      delete() {
        TeamsService.destroyMember(this.member).then(() => {
          if (this.member.current) {
            this.$alert.$show('You removed yourself from the team, you\'ll be redirected in 3 seconds...');
          } else {
            this.$alert.$show(`User '${this.member.display_name}' was successfully removed from the team`);
          }

          this.$bus.$emit('teamMemberDestroyed', this.member);
        }).catch(handleHttpResponseError);
      },

      update() {
        TeamsService.updateMember(this.member, this.selectedRole).then((response) => {
          const member = response.data;

          set(this, 'editing', false);
          this.$alert.$show(`User '${member.display_name}' was successfully updated`);
          this.$bus.$emit('teamMemberUpdated', member);
        }).catch(handleHttpResponseError);
      },
    },

    mounted() {
      const DELETE_BTN = '.delete-team-user-btn';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', DELETE_BTN, () => {
        const $yes = $(this.$el).find(DELETE_BTN).next().find('.yes');
        $yes.click(this.delete.bind(this));
      });
    },
  };
</script>
