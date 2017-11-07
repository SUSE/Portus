import Vue from 'vue';

import TeamsStore from '../store';

const { set } = Vue;

export default {
  data() {
    return {
      state: TeamsStore.state,
    };
  },

  computed: {
    canManageMembers() {
      return this.state.currentMember.admin ||
             (this.state.manageTeamsEnabled &&
              this.state.currentMember.role === 'owner');
    },
  },

  beforeMount() {
    const currentMember = window.teamMembers.find(m => m.current);

    set(this.state, 'currentMember', currentMember);
  },
};
