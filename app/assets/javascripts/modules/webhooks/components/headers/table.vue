<template>
  <div>
    <table class="table table-striped table-hover">
      <colgroup>
        <col class="col-20">
        <col class="col-70">
        <col class="col-10" v-if="webhook.updatable">
      </colgroup>
      <thead>
        <tr>
          <th>Name</th>
          <th>Value</th>
          <th v-if="webhook.updatable">Remove</th>
        </tr>
      </thead>
      <tbody>
        <webhook-header-table-row v-for="header in headers" :key="header.id" :header="header" :webhook="webhook"></webhook-header-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="headers.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import WebhookHeaderTableRow from './table-row';

  export default {
    props: ['webhook', 'headers'],

    mixins: [TableSortableMixin, TablePaginatedMixin],

    components: {
      WebhookHeaderTableRow,
    },
  };
</script>
