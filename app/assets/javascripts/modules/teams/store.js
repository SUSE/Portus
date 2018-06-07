import Vue from 'vue';

const { set } = Vue;

class TeamsStore {
  constructor() {
    this.state = {
      membersFormVisible: false,
      newFormVisible: false,
      editFormVisible: false,
      currentMember: {},
      availableRoles: [],
    };
  }

  setState(key, value) {
    set(this.state, key, value);
  }
}

export default new TeamsStore();
