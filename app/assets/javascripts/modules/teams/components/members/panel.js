import TeamMembersTable from './table';

export default {
  template: '#js-team-members-panel-tmpl',

  props: ['members'],

  components: {
    TeamMembersTable,
  },
};
