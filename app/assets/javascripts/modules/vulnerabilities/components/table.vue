<template>
  <div>
    <table class="table table-striped table-hover table-multiple-tbody vulnerabilities-table" :class="{'table-sortable': sortable}">
      <colgroup>
        <col width="10px">
        <col class="col-30">
        <col class="col-40">
        <col class="col-40">
      </colgroup>
      <thead>
        <tr>
          <th></th>
          <th @click="sort('name')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'name' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'name' && !sorting.asc,
            }"></i>
            CVE
          </th>
          <th @click="sort('severity')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'severity' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'severity' && !sorting.asc,
            }"></i>
            Severity
          </th>
          <th @click="sort('scanner')">
            <i class="fa fa-fw fa-sort" :class="{
              'fa-sort-amount-asc': sorting.by === 'scanner' && sorting.asc,
              'fa-sort-amount-desc': sorting.by === 'scanner' && !sorting.asc,
            }"></i>
            Scanned by
          </th>
        </tr>
      </thead>
      <vulnerability-table-row v-for="vulnerability in filteredVulnerabilities" :key="vulnerability.id" :vulnerability="vulnerability"></vulnerability-table-row>
    </table>
  </div>
</template>

<script>
  import getProperty from 'lodash/get';

  import Comparator from '~/utils/comparator';

  import TableSortableMixin from '~/shared/mixins/table-sortable';

  import VulnerabilityTableRow from './table-row';

  export default {
    props: {
      vulnerabilities: Array,
    },

    mixins: [TableSortableMixin],

    components: {
      VulnerabilityTableRow,
    },

    computed: {
      filteredVulnerabilities() {
        const isSeverity = this.sorting.by === 'severity';

        const order = this.sorting.asc ? 1 : -1;
        const sortedVulnerabilities = [...this.vulnerabilities];
        const sample = sortedVulnerabilities[0];
        const value = getProperty(sample, this.sorting.by);
        const comparator = isSeverity ? this.severityComparator : Comparator.of(value);

        // sorting
        sortedVulnerabilities.sort((a, b) => {
          const aValue = getProperty(a, this.sorting.by);
          const bValue = getProperty(b, this.sorting.by);

          return order * comparator(aValue, bValue);
        });

        return sortedVulnerabilities;
      },
    },

    methods: {
      severityComparator(a, b) {
        const severities = {
          Negligible: 0,
          Unknown: 1,
          Low: 2,
          Medium: 3,
          High: 4,
          Critical: 5,
          Defcon1: 6,
        };

        return severities[a] - severities[b];
      },
    },

    mounted() {
      if ($.fn.tooltip) {
        $('.has-tooltip').tooltip();
      }
    },
  };
</script>
