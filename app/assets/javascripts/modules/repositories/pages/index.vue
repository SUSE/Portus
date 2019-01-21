<template>
  <div class="repositories-index-page">
    <repositories-remote-panel title="Repositories you have access to through team membership" :repositories-endpoint="teamRepositoriesEndpoint" :repositories-path="repositoriesPath" :namespaces-path="namespacesPath"></repositories-remote-panel>
    <repositories-remote-panel title="Other repositories" :repositories-path="repositoriesPath" :namespaces-path="namespacesPath" :repositories-endpoint="otherRepositoriesEndpoint" prefix="o_"></repositories-remote-panel>
  </div>
</template>

<script>
  import RepositoriesRemotePanel from '../components/remote-panel';

  export default {
    props: {
      teamRepositoriesEndpoint: String,
      otherRepositoriesEndpoint: String,
      repositoriesPath: String,
      namespacesPath: String,
    },

    components: {
      RepositoriesRemotePanel,
    },
  };
</script>
