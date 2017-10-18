import Vue from 'vue';
import queryString from 'query-string';

import TablePagination from '~/shared/components/table-pagination';

const { set } = Vue;

export default {
  props: {
    limit: {
      type: Number,
      default: 10,
    },
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
      currentPage: 1,
    };
  },

  computed: {
    offset() {
      return (this.currentPage - 1) * this.limit;
    },
  },

  methods: {
    updateCurrentPage(page) {
      set(this, 'currentPage', page);

      this.updateUrlPaginationState();
    },

    updateUrlPaginationState() {
      const queryObject = queryString.parse(window.location.search);

      queryObject[this.prefix + 'page'] = this.currentPage;

      const queryParams = queryString.stringify(queryObject);
      const url = [location.protocol, '//', location.host, location.pathname].join('');
      history.pushState('', '', `${url}?${queryParams}`);
    },
  },

  beforeMount() {
    const queryObject = queryString.parse(window.location.search);
    const pageQuery = parseInt(queryObject[this.prefix + 'page'], 10) || this.currentPage;

    set(this, 'currentPage', pageQuery);
  },
};
