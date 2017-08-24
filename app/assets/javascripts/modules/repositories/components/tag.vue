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
  import Alert from '~/shared/components/alert';

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
        const $temp = $('<input>');

        $('body').append($temp);
        $temp.val(this.commandToPull).select();
        document.execCommand('copy');
        $temp.remove();

        Alert.show('Copied pull command to clipboard');
      },
    },
  };
</script>
