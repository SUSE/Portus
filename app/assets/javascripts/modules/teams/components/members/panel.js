import ToggleLink from '~/shared/components/toggle-link';

import TeamMembersTable from './table';

export default {
  template: '#js-team-members-panel-tmpl',

  props: ['members', 'team', 'state', 'currentMember'],

  components: {
    TeamMembersTable,
    ToggleLink,
  },
};
