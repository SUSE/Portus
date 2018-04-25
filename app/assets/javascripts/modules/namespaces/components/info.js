export default {
  template: '<div v-html="description"></div>',

  props: ['namespace'],

  computed: {
    description() {
      if (!this.namespace.description) {
        return 'No description has been posted yet';
      }

      return this.namespace.description_md;
    },
  },
};
