<template>
  <div>
    <table class="table table-striped table-hover">
      <colgroup>
        <col class="col-70">
        <col class="col-20">
        <col class="col-10" v-if="webhook.updatable">
      </colgroup>
      <thead>
        <tr>
          <th>UUID</th>
          <th>Last attempt</th>
          <th v-if="webhook.updatable">Retrigger</th>
        </tr>
      </thead>
      <tbody>
        <webhook-delivery-table-row v-for="delivery in deliveries" :key="delivery.id" :delivery="delivery" :webhook="webhook"></webhook-delivery-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="deliveries.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import WebhookDeliveryTableRow from './table-row';

  export default {
    props: ['deliveries', 'webhook'],

    mixins: [TableSortableMixin, TablePaginatedMixin],

    components: {
      WebhookDeliveryTableRow,
    },
  };
</script>
