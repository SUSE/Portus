<template>
  <div class="table-responsive">
    <table class="table table-striped table-hover">
      <colgroup>
        <col class="col-90">
        <col class="col-10">
      </colgroup>
      <thead>
        <tr>
          <th>Application</th>
          <th>Remove</th>
        </tr>
      </thead>
      <tbody>
        <app-token-table-row v-for="appToken in appTokens" :key="appToken.id" :app-token="appToken"></app-token-table-row>
      </tbody>
    </table>
  </div>
</template>

<script>
  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import AppTokenTableRow from './table-row';

  export default {
    props: ['appTokens'],

    mixins: [TableSortableMixin, TablePaginatedMixin],

    components: {
      AppTokenTableRow,
    },
  };
</script>
