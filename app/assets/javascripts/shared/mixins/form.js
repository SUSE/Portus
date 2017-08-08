import Vue from 'vue';

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
  },

  mounted() {
    this.$watch(`state.${this.formState}`, val => this.toggleAnimation(val));
  },
};
