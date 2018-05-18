import Vue from 'vue';

const { set } = Vue;

class WebhooksStore {
  constructor() {
    this.state = {
      newFormVisible: false,
      editFormVisible: false,
      newHeaderFormVisible: false,
    };
  }

  set(key, value) {
    set(this.state, key, value);
  }
}

export default new WebhooksStore();
