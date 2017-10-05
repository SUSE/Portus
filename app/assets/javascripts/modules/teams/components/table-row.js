export default {
  template: '#js-team-table-row-tmpl',

  props: ['team', 'teamsPath'],

  computed: {
    scopeClass() {
      return `team_${this.team.id}`;
    },

    teamIcon() {
      if (this.team.users_count > 1) {
        return 'fa-users';
      }
      return 'fa-user';
    },

    teamPath() {
      return `${this.teamsPath}/${this.team.id}`;
    },
  },
};
