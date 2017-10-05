export default {
  template: '#js-namespace-team-link-tmpl',

  props: ['teamsPath', 'namespace'],

  computed: {
    href() {
      return `${this.teamsPath}/${this.namespace.team_id}`;
    },
  },
};
