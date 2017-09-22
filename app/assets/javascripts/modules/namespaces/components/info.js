export default {
  template: '#js-namespace-info-tmpl',

  props: ['namespace'],

  computed: {
    description() {
      if (!this.namespace.description) {
        return 'No description has been posted yet';
      }

      return this.namespace.description;
    },
  },
};
