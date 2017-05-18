<template>
  <div class="form-inline pagination-wrapper">
    <div v-if="total === 0">
      No entry
    </div>
    <div class="col-sm-6 text-left" v-if="totalPages > 1">
      Showing from {{ start }} to {{ end }} of {{ total }} entries
    </div>
    <div class="col-sm-6 text-right" v-if="totalPages > 1">
      <ul class="pagination">
        <li v-if="!previousDisabled">
          <a href="#" @click.prevent="setCurrentPage(currentPage - 1)">Prev</a>
        </li>
        <li
          v-for="page in displayedPages"
          :class="{'active': currentPage == page}">
            <a href="#" @click.prevent="setCurrentPage(page)">{{ page }}</a>
        </li>
        <li v-if="!nextDisabled">
          <a href="#" @click.prevent="setCurrentPage(currentPage + 1)">Next</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
  import range from '~/utils/range';

  export default {
    template: `

    `,

    props: ['total', 'itensPerPage', 'currentPage'],

    data() {
      return {
        showMore: 2,
      };
    },

    computed: {
      start() {
        return ((this.currentPage * this.itensPerPage) - this.itensPerPage) + 1;
      },

      end() {
        const end = this.currentPage * this.itensPerPage;

        return end <= this.total ? end : this.total;
      },

      totalPages() {
        return Math.ceil(this.total / this.itensPerPage);
      },

      displayedPages() {
        let minRange = this.currentPage - this.showMore;
        let maxRange = this.currentPage + this.showMore;

        const distanceLeft = Math.abs(1 - minRange);
        const distanceRight = Math.abs(this.totalPages - maxRange);

        if (minRange <= 0 && maxRange < this.totalPages) {
          maxRange += distanceLeft;
        }

        if (maxRange > this.totalPages && minRange > 1) {
          minRange -= distanceRight;
        }

        const start = minRange < 1 ? 1 : minRange;
        const end = maxRange > this.totalPages ? this.totalPages : maxRange;

        return range(start, end);
      },

      previousDisabled() {
        return this.currentPage === 1;
      },

      nextDisabled() {
        return this.currentPage === this.totalPages;
      },
    },

    methods: {
      setCurrentPage(page) {
        this.$emit('update:currentPage', page);
      },
    },
  };
</script>
