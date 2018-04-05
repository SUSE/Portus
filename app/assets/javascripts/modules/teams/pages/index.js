import Vue from 'vue';

import ToggleLink from '~/shared/components/toggle-link';

import NewTeamForm from '../components/new-form';
import TeamsTable from '../components/table';
import TeamsStore from '../store';

const { set } = Vue;

$(() => {
  if (!$('body[data-route="teams/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      ToggleLink,
      NewTeamForm,
      TeamsTable,
    },

    data() {
      return {
        state: TeamsStore.state,
        teams: window.teams,
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
  });
});
