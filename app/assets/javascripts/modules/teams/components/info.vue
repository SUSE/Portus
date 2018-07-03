<template>
  <div v-html="description"></div>
</template>

<script>
  export default {
    props: ['team'],

    computed: {
      description() {
        if (this.team.description) {
          return this.team.description_md;
        }

        return 'No description has been posted yet';
      },
    },
  };
</script>
