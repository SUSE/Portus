<template>
  <panel class="namespaces-panel">
    <div slot="heading-left">
      <slot name="name"></slot>
    </div>

    <toggle-link slot="heading-right" text="Create" :state="state" state-key="newFormVisible" class="toggle-link-new-namespace" v-if="canCreate"></toggle-link>

    <div slot="body">
      <loading-icon v-if="state.isLoading"></loading-icon>
      <div class="table-responsive">
        <namespaces-not-loaded v-if="state.notLoaded"></namespaces-not-loaded>
        <namespaces-table v-if="!state.isLoading && !state.notLoaded" :namespaces="namespaces" :sortable="tableSortable" sort-by="name" :prefix="prefix" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath"></namespaces-table>
      </div>
    </div>
  </panel>
</template>

<script>
  import NamespacesTable from './table';

  import NamespacesStore from '../store';

  export default {
    props: ['namespaces', 'namespacesPath', 'webhooksPath', 'tableSortable', 'prefix', 'canCreate'],

    data() {
      return {
        state: NamespacesStore.state,
      };
    },

    components: {
      NamespacesTable,
    },
  };
</script>
