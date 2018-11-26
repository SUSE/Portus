<template>
  <div class="table-responsive">
    <loading-icon v-if="isLoading"></loading-icon>
    <table class="table table-striped table-hover" :class="{'table-sortable': sortable}" v-if="!isLoading">
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
          <th class="no-sort" v-if="showNamespaces">Namespace</th>
          <th class="no-sort">Tags</th>
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
        <repository-table-row v-for="repository in repositories" :key="repository.id" :repository="repository" :repositories-path="repositoriesPath" :namespaces-path="namespacesPath" :show-namespaces="showNamespaces"></repository-table-row>
      </tbody>
    </table>

    <table-pagination :total.sync="total" :total-pages.sync="totalPages" :current-page="currentPage" :itens-per-page.sync="perPage" @update="updateCurrentPage" v-if="!isLoading"></table-pagination>
  </div>
</template>

<script>
  import Vue from 'vue';

  import TableSortableMixin from '~/shared/mixins/table-sortable';
  import TablePaginatedMixin from '~/shared/mixins/table-paginated';

  import RepositoryTableRow from './table-row';

  const { set } = Vue;

  export default {
    props: {
      repositoriesEndpoint: {
        type: String,
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

    data() {
      return {
        repositories: [],
        total: 0,
        isLoading: false,
      };
    },

    watch: {
      'sorting.by': 'fetchRepositories',
      'sorting.asc': 'fetchRepositories',
      currentPage: 'fetchRepositories',
    },

    methods: {
      fetchRepositories() {
        if (this.isLoading) {
          return;
        }

        const params = {
          page: this.currentPage,
          sort_attr: this.sorting.by,
          sort_order: this.sorting.asc ? 'asc' : 'desc',
        };

        set(this, 'isLoading', true);
        this.$http.get(this.repositoriesEndpoint, { params }).then((response) => {
          const repositories = response.data;

          set(this, 'repositories', repositories);
          set(this, 'total', parseInt(response.headers.get('X-Total'), 10));
          set(this, 'totalPages', parseInt(response.headers.get('X-Total-Pages'), 10));
          set(this, 'isLoading', false);
        });
      },
    },
  };
</script>
