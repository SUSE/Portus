import Vue from 'vue';

const { set } = Vue;

export default {
  props: ['state', 'formState'],

  methods: {
    toggleForm() {
      set(this.state, this.formState, !this.state[this.formState]);
    },
  },
};
