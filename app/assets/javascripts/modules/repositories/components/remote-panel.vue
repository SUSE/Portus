<template>
  <panel class="repositories-panel">
    <h5 slot="heading-left">
      {{ title }}
    </h5>

    <div slot="heading-right">
      <slot name="heading-right"></slot>
    </div>

    <div slot="body">
      <repositories-remote-table :repositories-endpoint="repositoriesEndpoint" :repositories-path="repositoriesPath" :namespaces-path="namespacesPath" :sortable="true" sort-by="name" :prefix="prefix" :show-namespaces="showNamespaces"></repositories-remote-table>
    </div>
  </panel>
</template>

<script>
  import RepositoriesRemoteTable from './remote-table';

  export default {
    props: {
      title: {
        type: String,
        default: 'Repositories',
      },
      showNamespaces: {
        type: Boolean,
        default: true,
      },
      repositoriesEndpoint: String,
      repositoriesPath: String,
      namespacesPath: String,
      prefix: String,
    },

    components: {
      RepositoriesRemoteTable,
    },
  };
</script>
