<template>
  <div>
    <table class="table table-striped table-hover" :class="{'table-sortable': sortable}">
      <colgroup>
        <col class="col-40">
        <col class="col-15">
        <col class="col-15">
        <col class="col-20">
        <col width="160px">
      </colgroup>
      <thead>
        <tr>
          <th @click="sort('name')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'name' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'name' && !sorting.asc,
            }"></i>
            Name
          </th>
          <th @click="sort('repositories_count')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'repositories_count' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'repositories_count' && !sorting.asc,
            }"></i>
            Repositories
          </th>
          <th @click="sort('webhooks_count')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'webhooks_count' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'webhooks_count' && !sorting.asc,
            }"></i>
            Webhooks
          </th>
          <th @click="sort('created_at')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'created_at' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'created_at' && !sorting.asc,
            }"></i>
            Created at
          </th>
          <th @click="sort('visibility')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'visibility' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'visibility' && !sorting.asc,
            }"></i>
            Visibility
          </th>
        </tr>
      </thead>
      <tbody>
        <namespace-table-row v-for="namespace in filteredNamespaces" :key="namespace.id" :namespace="namespace" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath"></namespace-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="namespaces.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import getProperty from 'lodash/get';

  import Comparator from '~/utils/comparator';

  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import NamespaceTableRow from './table-row';

  export default {
    props: {
      namespaces: {
        type: Array,
      },
      namespacesPath: {
        type: String,
      },
      webhooksPath: {
        type: String,
      },
      prefix: {
        type: String,
        default: 'ns_',
      },
    },

    mixins: [TableSortableMixin, TablePaginatedMixin],

    components: {
      NamespaceTableRow,
    },

    computed: {
      filteredNamespaces() {
        const order = this.sorting.asc ? 1 : -1;
        const sortedNamespaces = [...this.namespaces];
        const sample = sortedNamespaces[0];
        const value = getProperty(sample, this.sorting.by);
        const comparator = Comparator.of(value);

        // sorting
        sortedNamespaces.sort((a, b) => {
          const aValue = getProperty(a, this.sorting.by);
          const bValue = getProperty(b, this.sorting.by);

          return order * comparator(aValue, bValue);
        });

        // pagination
        const slicedNamespaces = sortedNamespaces.slice(this.offset, this.perPage * this.currentPage);

        return slicedNamespaces;
      },
    },
  };
</script>
