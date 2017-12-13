export default {
  template: '#js-namespace-team-link-tmpl',

  props: ['teamsPath', 'teamId', 'teamName'],

  computed: {
    href() {
      return `${this.teamsPath}/${this.teamId}`;
    },
  },
};
