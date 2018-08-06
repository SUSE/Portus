<style scoped>
  .label {
    cursor: pointer;
  }
</style>

<template>
  <div class="label label-success" title="Copy to clipboard" @click="copyToClipboard">
    {{ tag.name }}
  </div>
</template>

<script>
  export default {
    props: ['tag', 'repository'],

    computed: {
      commandToPull() {
        const hostname = this.repository.registry_hostname;
        const repoName = this.repository.full_name;
        const tagName = this.tag.name;

        return `docker pull ${hostname}/${repoName}:${tagName}`;
      },
    },

    methods: {
      copyToClipboard() {
        const tempInput = document.createElement('input');

        document.body.appendChild(tempInput);
        tempInput.value = this.commandToPull;
        tempInput.select();
        document.execCommand('copy');
        tempInput.parentNode.removeChild(tempInput);

        this.$alert.$show('Copied pull command to clipboard');
      },
    },
  };
</script>
