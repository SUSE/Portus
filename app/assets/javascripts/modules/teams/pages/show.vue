<template>
  <div class="teams-show-page">
    <team-details-panel :team="team" :state="teamsState" :teams-path="teamsPath"></team-details-panel>
    <new-team-member-form :state="teamsState" form-state="membersFormVisible" :team-id="team.id"></new-team-member-form>
    <team-members-panel :members="members" :team="team" :state="teamsState" :current-member="currentMember"></team-members-panel>
    <new-namespace-form :state="namespaceState" form-state="newFormVisible" :team-name="team.name"></new-namespace-form>
    <namespaces-panel :namespaces="namespaces" :namespaces-path="namespacesPath" webhooks-path="webhooks" :table-sortable="true" :can-create="team.updatable">
      <h5 slot="name">
        <a data-placement="right"
          data-toggle="popover"
          data-container=".panel-heading"
          data-content='<p>A team can own one or more namespaces. By default all the namespaces can be accessed only by the members of the team.</p><p>It is possible to add read only (pull) access to logged-in users or all Portus users by changing the visibility to "protected" or "public" respectively.</p>'
          data-original-title="What's this?"
          tabindex="0"
          data-html="true">
          <i class="fa fa-info-circle"></i>
        </a>
        Namespaces
      </h5>
    </namespaces-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import TeamDetailsPanel from '../components/details';

  import NamespacesPanel from '../../namespaces/components/panel';
  import NewNamespaceForm from '../../namespaces/components/new-form';

  import NamespacesStore from '../../namespaces/store';

  import TeamMembersPanel from '../components/members/panel';
  import NewTeamMemberForm from '../components/members/form';

  import TeamsStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      teamRef: {
        type: Object,
      },
      namespacesRef: {
        type: Array,
      },
      membersRef: {
        type: Array,
      },
      namespacesPath: {
        type: String,
      },
      currentMemberRef: {
        type: Object,
      },
      manageTeamsEnabled: {
        type: Boolean,
      },
      availableRoles: {
        type: Array,
      },
      teamsPath: {
        type: String,
      },
    },

    components: {
      TeamDetailsPanel,
      NewNamespaceForm,
      NamespacesPanel,
      NewTeamMemberForm,
      TeamMembersPanel,
    },

    data() {
      return {
        team: { ...this.teamRef },
        teamsState: TeamsStore.state,
        namespaceState: NamespacesStore.state,
        namespaces: [...this.namespacesRef],
        members: [...this.membersRef],
        currentMember: { ...this.currentMemberRef },
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
      TeamsStore.setState('manageTeamsEnabled', this.manageTeamsEnabled);
      TeamsStore.setState('availableRoles', this.availableRoles);
    },

    mounted() {
      this.$bus.$on('namespaceCreated', namespace => this.onCreate(namespace));
      this.$bus.$on('teamMemberAdded', member => this.onMemberAdd(member));
      this.$bus.$on('teamMemberDestroyed', teamMember => this.onMemberDestroy(teamMember));
      this.$bus.$on('teamMemberUpdated', teamMember => this.onMemberUpdate(teamMember));
      this.$bus.$on('teamUpdated', teamMember => this.onTeamUpdate(teamMember));
    },
  };
</script>
