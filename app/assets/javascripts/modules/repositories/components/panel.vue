<template>
  <panel class="repositories-panel">
    <h5 slot="heading-left">
      {{ title }}
    </h5>

    <div slot="heading-right">
      <slot name="heading-right"></slot>
    </div>

    <div slot="body">
      <repositories-table :repositories="repositories" :repositories-path="repositoriesPath" :namespaces-path="namespacesPath" :sortable="true" sort-by="name" :show-namespaces="showNamespaces"></repositories-table>
    </div>
  </panel>
</template>

<script>
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
      RepositoriesTable,
    },
  };
</script>
