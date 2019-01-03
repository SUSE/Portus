<template>
  <div>
    <loading-icon v-if="state.isLoading"></loading-icon>
    <tags-not-loaded v-if="state.notLoaded"></tags-not-loaded>
    <tags-table v-if="!state.isLoading && !state.notLoaded" :tags="tags" :can-destroy="repository.destroyable" :state="state" :security-enabled="securityEnabled" :tags-path="tagsPath" :repository="repository"></tags-table>
  </div>
</template>

<script>
  import TagsTable from './tags-table';
  import TagsNotLoaded from './tags-not-loaded';

  export default {
    props: {
      state: Object,
      repository: Object,
      tags: Array,
      tagsPath: String,
      securityEnabled: Boolean,
    },

    components: {
      TagsTable,
      TagsNotLoaded,
    },
  };
</script>
