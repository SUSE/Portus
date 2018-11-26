import Vue from 'vue';
import queryString from 'query-string';

import TablePagination from '~/shared/components/table-pagination';

const { set } = Vue;

export default {
  props: {
    prefix: {
      type: String,
      default: '',
    },
  },

  components: {
    TablePagination,
  },

  data() {
    return {
      perPage: this.$config.pagination.perPage,
      currentPage: 1,
      totalPages: 1,
    };
  },

  computed: {
    offset() {
      return (this.currentPage - 1) * this.perPage;
    },

    pageParam() {
      return this.prefix + 'page';
    },
  },

  methods: {
    updateCurrentPage(page) {
      set(this, 'currentPage', page);

      this.updateUrlPaginationState();
    },

    updateUrlPaginationState() {
      const queryObject = queryString.parse(window.location.search);

      queryObject[this.pageParam] = this.currentPage;

      const queryParams = queryString.stringify(queryObject);
      const url = [
        window.location.protocol,
        '//',
        window.location.host,
        window.location.pathname,
      ].join('');

      window.history.pushState('', '', `${url}?${queryParams}`);
    },
  },

  beforeMount() {
    const queryObject = queryString.parse(window.location.search);
    const pageQuery = parseInt(queryObject[this.pageParam], 10) || 1;

    set(this, 'currentPage', pageQuery);
  },
};
