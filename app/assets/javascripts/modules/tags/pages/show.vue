<template>
  <div class="tags-show-page">
    <vulnerabilities-panel :tag="tag" :vulnerabilities="tag.vulnerabilities" :namespace-name="namespaceName" :namespace-path="namespacePath" :repository-name="repositoryName" :repository-path="repositoryPath"></vulnerabilities-panel>
  </div>
</template>

<script>
  import VulnerabilitiesPanel from '~/modules/vulnerabilities/components/panel';

  export default {
    props: {
      tagRef: Object,
      namespacePath: String,
      namespaceName: String,
      repositoryPath: String,
      repositoryName: String,
    },

    components: {
      VulnerabilitiesPanel,
    },

    data() {
      return {
        tag: { ...this.tagRef },
      };
    },
  };
</script>
