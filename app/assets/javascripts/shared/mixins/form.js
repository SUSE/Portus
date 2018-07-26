import Vue from 'vue';

const touchMap = {};

const { set } = Vue;

export default {
  props: ['state', 'formState'],

  methods: {
    // public
    toggleForm(visible) {
      let value;

      if (typeof visible === 'undefined') {
        value = !this.state[this.formState];
      } else {
        value = visible;
      }

      set(this.state, this.formState, value);
    },

    // internal
    toggleAnimation(visible) {
      $(this.$refs.form).toggle(400, 'swing', () => {
        if (visible) {
          $(this.$refs.firstField).focus();
        }

        layout_resizer();
      });
    },

    delayTouch($v, timeout = 1000) {
      $v.reset();
      if (touchMap[$v]) {
        clearTimeout(touchMap[$v]);
      }
      touchMap[$v] = setTimeout($v.$touch, timeout);
    },
  },

  mounted() {
    this.$watch(`state.${this.formState}`, val => this.toggleAnimation(val));
  },
};
