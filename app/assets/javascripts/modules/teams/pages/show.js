import Vue from 'vue';

import ToggleLink from '~/shared/components/toggle-link';

import TeamEditForm from '../components/edit-form';
import TeamInfo from '../components/info';

import NamespacesPanel from '../../namespaces/components/panel';
import NewNamespaceForm from '../../namespaces/components/new-form';

import NamespacesStore from '../../namespaces/store';

import TeamMembersPanel from '../components/members/panel';
import NewTeamMemberForm from '../components/members/form';

import TeamsStore from '../store';

const { set } = Vue;

$(() => {
  if (!$('body[data-route="teams/show"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="teams/show"] .vue-root',

    components: {
      TeamEditForm,
      TeamInfo,
      NewNamespaceForm,
      NamespacesPanel,
      NewTeamMemberForm,
      TeamMembersPanel,
      ToggleLink,
    },

    data() {
      return {
        team: window.team,
        teamsState: TeamsStore.state,
        namespaceState: NamespacesStore.state,
        namespaces: window.teamNamespaces,
        members: window.teamMembers || [],
        teamsPath: window.teamsPath,
      };
    },

    methods: {
      onCreate(namespace) {
        const currentNamespaces = this.namespaces;
        const namespaces = [
          ...currentNamespaces,
          namespace,
        ];

        set(this, 'namespaces', namespaces);
      },

      onMemberAdd(member) {
        const currentMembers = this.members;
        const members = [
          ...currentMembers,
          member,
        ];

        set(this, 'members', members);
      },

      onMemberUpdate(teamMember) {
        const currentTeamMembers = this.members;
        const index = currentTeamMembers.findIndex(t => t.id === teamMember.id);

        const members = [
          ...currentTeamMembers.slice(0, index),
          teamMember,
          ...currentTeamMembers.slice(index + 1),
        ];

        set(this, 'members', members);

        if (teamMember.current) {
          TeamsStore.setState('currentMember', teamMember);
        }
      },

      onMemberDestroy(teamMember) {
        const currentTeamMembers = this.members;
        const index = currentTeamMembers.findIndex(t => t.id === teamMember.id);

        const members = [
          ...currentTeamMembers.slice(0, index),
          ...currentTeamMembers.slice(index + 1),
        ];

        set(this, 'members', members);

        if (teamMember.current) {
          setTimeout(() => { window.location.href = this.teamsPath; }, 3000);
        }
      },

      onTeamUpdate(team) {
        set(this, 'team', team);
        TeamsStore.setState('editFormVisible', false);
      },
    },

    beforeMount() {
      TeamsStore.setState('manageTeamsEnabled', window.manageTeamsEnabled);
    },

    mounted() {
      this.$bus.$on('namespaceCreated', namespace => this.onCreate(namespace));
      this.$bus.$on('teamMemberAdded', member => this.onMemberAdd(member));
      this.$bus.$on('teamMemberDestroyed', teamMember => this.onMemberDestroy(teamMember));
      this.$bus.$on('teamMemberUpdated', teamMember => this.onMemberUpdate(teamMember));
      this.$bus.$on('teamUpdated', teamMember => this.onTeamUpdate(teamMember));
    },
  });
});
