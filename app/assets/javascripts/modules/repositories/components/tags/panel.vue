<template>
  <panel>
    <h5 slot="heading-left">Tags</h5>

    <div slot="heading-right" v-if="repository.destroyable">
      <delete-tag-action :state="state"></delete-tag-action>
    </div>

    <div slot="body">
      <loading-icon v-if="state.isLoading"></loading-icon>

      <div class="table-responsive tags">
        <tags-not-loaded v-if="state.notLoaded"></tags-not-loaded>
        <tags-table v-if="!state.isLoading && !state.notLoaded" :tags="tags" :can-destroy="repository.destroyable" :state="state" :security-enabled="securityEnabled" :tags-path="tagsPath" :repository="repository"></tags-table>
      </div>
    </div>
  </panel>
</template>

<script>
  import TagsTable from './tags-table';
  import TagsNotLoaded from './tags-not-loaded';
  import DeleteTagAction from './delete-tag-action';

  export default {
    props: {
      state: {
        type: Object,
      },
      repository: {
        type: Object,
      },
      securityEnabled: {
        type: Boolean,
      },
      tags: {
        type: Array,
      },
      tagsPath: {
        type: String,
      },
    },

    components: {
      TagsTable,
      TagsNotLoaded,
      DeleteTagAction,
    },
  };
</script>
