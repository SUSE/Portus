import Vue from 'vue';

import { handleHttpResponseError } from '~/utils/http';

import TeamsService from '../../service';
import MembersPermissions from '../../mixins/members-permissions';

const { set } = Vue;

export default {
  template: '#js-team-members-table-row-tmpl',

  props: ['member'],

  mixins: [MembersPermissions],

  data() {
    return {
      editing: false,
      selectedRole: this.member.role,
      availableRoles: window.availableRoles,
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
