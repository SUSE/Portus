<template>
  <div>
    <table class="table table-striped table-hover">
      <colgroup>
        <col class="col-40">
        <col class="col-20">
        <col class="col-20">
        <col class="col-10" v-if="canCreateWebhook">
        <col class="col-10" v-if="canCreateWebhook">
        <col class="col-20" v-else>
      </colgroup>
      <thead>
        <tr>
          <th>Name</th>
          <th>URL</th>
          <th>Request method</th>
          <th>Content type</th>
          <th>Enabled</th>
          <th v-if="canCreateWebhook">Remove</th>
        </tr>
      </thead>
      <tbody>
        <webhook-table-row v-for="webhook in webhooks" :key="webhook.id" :webhook="webhook" :webhooks-path="webhooksPath"></webhook-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="webhooks.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import WebhookTableRow from './table-row';

  export default {
    props: ['webhooks', 'webhooksPath', 'canCreateWebhook'],

    mixins: [TableSortableMixin, TablePaginatedMixin],

    components: {
      WebhookTableRow,
    },
  };
</script>
