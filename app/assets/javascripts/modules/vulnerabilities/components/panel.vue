<template>
  <panel>
    <h5 slot="heading-left">Vulnerabilities for tag <b>{{ tag.name }}</b> of <a :href="namespacePath">{{ namespaceName }}</a>/<a :href="repositoryPath">{{ repositoryName }}</a></h5>

    <div slot="body">
      <vulnerabilities-summary :vulnerabilities="vulnerabilities"></vulnerabilities-summary>
      <hr v-if="vulnerabilities.length > 0" />
      <vulnerabilities-table :vulnerabilities="vulnerabilities" :sortable="true" sort-by="severity" sort-asc="false" v-if="vulnerabilities.length > 0"></vulnerabilities-table>
    </div>
  </panel>
</template>

<script>
  import VulnerabilitiesTable from './table';
  import VulnerabilitiesSummary from './summary';

  export default {
    props: {
      tag: Object,
      vulnerabilities: Array,
      namespacePath: String,
      namespaceName: String,
      repositoryPath: String,
      repositoryName: String,
    },

    components: {
      VulnerabilitiesTable,
      VulnerabilitiesSummary,
    },
  };
</script>
