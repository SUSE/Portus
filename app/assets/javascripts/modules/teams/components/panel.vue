<template>
  <panel>
    <h5 slot="heading-left">{{ title }}</h5>

    <toggle-link slot="heading-right" text="Create" :state="state" state-key="newFormVisible" class="toggle-link-new-team" v-if="canCreate"></toggle-link>

    <div slot="body">
      <teams-table :teams="teams" :sortable="true" sort-by="name" :teams-path="teamsPath"></teams-table>
    </div>
  </panel>
</template>

<script>
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
      TeamsTable,
    },
  };
</script>
