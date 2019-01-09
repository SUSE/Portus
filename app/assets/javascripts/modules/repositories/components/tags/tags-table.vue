<template>
  <div>
    <table class="table table-striped table-hover no-margin">
      <colgroup>
        <col width="10" v-if="canDestroy">
        <col>
        <col width="120">
        <col width="120">
        <col width="70">
        <col width="130">
        <col width="155" v-if="securityEnabled">
      </colgroup>
      <thead>
        <tr>
          <th v-if="canDestroy"></th>
          <th>Tag</th>
          <th>Author</th>
          <th>Image</th>
          <th>Size</th>
          <th>Last modified</th>
          <th v-if="securityEnabled">Security</th>
        </tr>
      </thead>
      <tbody>
        <tag-row v-for="tag in filteredTags" :key="tag[0].digest" :tag="tag" :can-destroy="canDestroy" :security-enabled="securityEnabled" :state="state" :tags-path="tagsPath" :repository="repository"></tag-row>
      </tbody>
    </table>

    <table-pagination :total.sync="tags.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import TagRow from './tags-table-row';

  export default {
    props: {
      tags: Array,
      canDestroy: Boolean,
      securityEnabled: Boolean,
      state: Object,
      tagsPath: String,
      repository: Object,
    },

    mixins: [TablePaginatedMixin],

    components: {
      TagRow,
    },

    computed: {
      filteredTags() {
        return this.tags.slice(this.offset, this.perPage * this.currentPage);
      },
    },

    mounted() {
      if ($.fn.tooltip) {
        $('.has-tooltip').tooltip();
      }
    },
  };
</script>
