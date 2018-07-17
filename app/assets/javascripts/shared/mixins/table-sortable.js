import Vue from 'vue';
import queryString from 'query-string';

const { set } = Vue;

export default {
  props: {
    sortable: {
      type: Boolean,
      default: true,
    },
    sortBy: {
      type: String,
      required: true,
    },
    // Seems stupid to set it as String but I wanted
    // to have the type equal to the query string.
    // I can handle is the same way as the query string.
    sortAsc: {
      type: String,
      default: 'true',
    },
    prefix: {
      type: String,
      default: '',
    },
  },

  data() {
    return {
      sorting: {
        by: this.sortBy,
        asc: this.sortAsc,
      },
    };
  },

  methods: {
    sort(attribute) {
      if (!this.sortable) {
        return;
      }

      // if sort column has changed, go always asc
      // inverse current order otherwise
      if (this.sorting.by === attribute) {
        set(this.sorting, 'asc', !this.sorting.asc);
      } else {
        set(this.sorting, 'asc', true);
      }

      set(this.sorting, 'by', attribute);

      this.updateUrlSortingState();
    },

    updateUrlSortingState() {
      const queryObject = queryString.parse(window.location.search);

      queryObject[this.prefix + 'sort_asc'] = this.sorting.asc;
      queryObject[this.prefix + 'sort_by'] = this.sorting.by;

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
    if (!this.sortable) {
      return;
    }

    const queryObject = queryString.parse(window.location.search);
    const sortByQuery = queryObject[this.prefix + 'sort_by'] || this.sorting.by;
    const sortAscQuery = (queryObject[this.prefix + 'sort_asc'] || this.sorting.asc) === 'true';

    set(this.sorting, 'by', sortByQuery);
    set(this.sorting, 'asc', sortAscQuery);
  },
};
