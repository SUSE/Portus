<template>
  <div>
    <table class="table table-striped table-hover">
      <colgroup>
        <col width="10" v-if="canDestroy">
        <col class="col-45">
        <col class="col-20">
        <col class="col-10">
        <col class="col-15">
        <col class="col-10" v-if="securityEnabled">
      </colgroup>
      <thead>
        <tr>
          <th v-if="canDestroy"></th>
          <th>Tag</th>
          <th>Author</th>
          <th>Image</th>
          <th>Pushed at</th>
          <th v-if="securityEnabled">Security</th>
        </tr>
      </thead>
      <tbody>
        <tag-row v-for="tag in filteredTags" :key="tag[0].id" :tag="tag" :can-destroy="canDestroy" :security-enabled="securityEnabled" :state="state"></tag-row>
      </tbody>
    </table>

    <table-pagination :total.sync="tags.length" :current-page.sync="currentPage" :itens-per-page.sync="limit"></table-pagination>
  </div>
</template>

<script>
  import TablePagination from '~/shared/components/table-pagination';

  import TagRow from './tags-table-row';

  export default {
    props: {
      tags: Array,
      canDestroy: Boolean,
      securityEnabled: Boolean,
      state: Object,
    },

    components: {
      TagRow,
      TablePagination,
    },

    data() {
      return {
        limit: 3,
        currentPage: 1,
      };
    },

    computed: {
      offset() {
        return (this.currentPage - 1) * this.limit;
      },

      filteredTags() {
        return this.tags.slice(this.offset, this.limit * this.currentPage);
      },
    },
  };
</script>
