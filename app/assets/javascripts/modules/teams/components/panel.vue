<template>
  <panel>
    <h5 slot="heading-left">{{ title }}</h5>

    <div slot="heading-right" v-if="canCreate">
      <toggle-link text="Create new team" :state="state" state-key="newFormVisible" class="toggle-link-new-team"></toggle-link>
    </div>

    <div slot="body">
      <teams-table :teams="teams" :sortable="true" sort-by="name" :teams-path="teamsPath"></teams-table>
    </div>
  </panel>
</template>

<script>
  import Panel from '~/shared/components/panel';
  import ToggleLink from '~/shared/components/toggle-link';

  import TeamsTable from './table';

  export default {
    props: {
      title: {
        type: String,
        default: 'Teams',
      },
      teams: {
        type: Array,
      },
      teamsPath: {
        type: String,
      },
      canCreate: {
        type: Boolean,
      },
      state: {
        type: Object,
      },
    },

    components: {
      Panel,
      ToggleLink,
      TeamsTable,
    },
  };
</script>
