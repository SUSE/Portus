<template>
  <div class="teams-index-page">
    <new-team-form :state="state" form-state="newFormVisible" :owners="owners" :is-admin="isAdmin" :current-user-id="currentUserId"></new-team-form>
    <teams-panel title="Teams you are member of" :teams="myTeams" :teams-path="teamsPath" :can-create="canCreate" :state="state"></teams-panel>
    <teams-panel title="Other teams" :teams="otherTeams" :teams-path="teamsPath" v-if="isAdmin && otherTeams.length > 0"></teams-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import NewTeamForm from '../components/new-form';
  import TeamsPanel from '../components/panel';

  import TeamsStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      teamsRef: {
        type: Array,
      },
      teamsPath: {
        type: String,
      },
      ownersRef: {
        type: Array,
      },
      isAdmin: {
        type: Boolean,
      },
      canCreate: {
        type: Boolean,
      },
      currentUserId: {
        type: Number,
      },
    },

    components: {
      TeamsPanel,
      NewTeamForm,
    },

    data() {
      return {
        state: TeamsStore.state,
        teams: [...this.teamsRef],
        owners: [...this.ownersRef],
      };
    },

    computed: {
      myTeams() {
        return this.teams.filter(t => t.role);
      },

      otherTeams() {
        return this.teams.filter(t => !t.role);
      },
    },

    methods: {
      onCreate(team) {
        const currentTeams = this.teams;
        const teams = [
          ...currentTeams,
          team,
        ];

        set(this, 'teams', teams);
      },
    },

    mounted() {
      this.$bus.$on('teamCreated', team => this.onCreate(team));
    },
  };
</script>
