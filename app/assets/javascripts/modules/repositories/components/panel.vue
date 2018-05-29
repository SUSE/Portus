<template>
  <panel class="repositories-panel">
    <h5 slot="heading-left">
      {{ title }}
    </h5>

    <div slot="body">
      <repositories-table :repositories="repositories" :repositories-path="repositoriesPath" :namespaces-path="namespacesPath" :sortable="true" sort-by="name"></repositories-table>
    </div>
  </panel>
</template>

<script>
  import Panel from '~/shared/components/panel';

  import RepositoriesTable from './table';

  export default {
    props: {
      title: {
        type: String,
        default: 'Repositories',
      },
      repositories: {
        type: Array,
      },
      repositoriesPath: {
        type: String,
      },
      namespacesPath: {
        type: String,
      },
      showNamespaces: {
        type: Boolean,
        default: true,
      },
    },

    components: {
      Panel,
      RepositoriesTable,
    },
  };
</script>
