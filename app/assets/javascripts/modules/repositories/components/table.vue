<template>
  <div class="table-responsive">
    <table class="table table-striped table-hover" :class="{'table-sortable': sortable}">
      <colgroup>
        <col class="col-60">
      </colgroup>
      <thead>
        <tr>
          <th @click="sort('name')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'name' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'name' && !sorting.asc,
            }"></i>
            Repository
          </th>
          <th @click="sort('namespace.name')" v-if="showNamespaces">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'namespace.name' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'namespace.name' && !sorting.asc,
            }"></i>
            Namespace
          </th>
          <th @click="sort('tags_count')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'tags_count' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'tags_count' && !sorting.asc,
            }"></i>
            Tags
          </th>
          <th @click="sort('updated_at')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'updated_at' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'updated_at' && !sorting.asc,
            }"></i>
            Updated at
          </th>
        </tr>
      </thead>
      <tbody>
        <repository-table-row v-for="repository in filteredRepositories" :key="repository.id" :repository="repository" :repositories-path="repositoriesPath" :namespaces-path="namespacesPath" :show-namespaces="showNamespaces"></repository-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="repositories.length" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage"></table-pagination>
  </div>
</template>

<script>
  import getProperty from 'lodash/get';

  import Comparator from '~/utils/comparator';

  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import RepositoryTableRow from './table-row';

  export default {
    props: {
      repositories: {
        type: Array,
      },
      repositoriesPath: {
        type: String,
      },
      namespacesPath: {
        type: String,
      },
      showNamespaces: {
        type: Boolean,
        default: true,
      },
      prefix: {
        type: String,
        default: '',
      },
    },

    mixins: [TableSortableMixin, TablePaginatedMixin],

    components: {
      RepositoryTableRow,
    },

    computed: {
      filteredRepositories() {
        const order = this.sorting.asc ? 1 : -1;
        const sortedRepositories = [...this.repositories];
        const sample = sortedRepositories[0];
        const value = getProperty(sample, this.sorting.by);
        const comparator = Comparator.of(value);

        // sorting
        sortedRepositories.sort((a, b) => {
          const aValue = getProperty(a, this.sorting.by);
          const bValue = getProperty(b, this.sorting.by);

          return order * comparator(aValue, bValue);
        });

        // pagination
        const slicedTeams = sortedRepositories.slice(this.offset, this.perPage * this.currentPage);

        return slicedTeams;
      },
    },
  };
</script>
