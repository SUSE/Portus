export default {
  template: '<div v-html="description"></div>',

  props: ['team'],

  computed: {
    description() {
      if (this.team.description) {
        return this.team.description_md;
      }

      return 'No description has been posted yet';
    },
  },
};
