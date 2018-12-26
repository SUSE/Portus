<template>
  <span>
    <span v-if="total > 0" >
      <span :class="severityClass"><i class="fa fa-warning"></i> {{ highestSeverityNumber }} {{ highestSeverity }}</span> - <span class="total">{{ total }} total</span>
    </span>
    <span v-else class="severity-passed">
      <i class="fa fa-check"></i> Passed
    </span>
  </span>
</template>

<script>
  import VulnerabilitiesParser from '~/modules/repositories/services/vulnerabilities-parser';

  export default {
    props: {
      vulnerabilities: {
        type: Array,
        default: [],
      },
    },

    computed: {
      severityClass() {
        return `severity-${this.highestSeverity.toLowerCase()}`;
      },

      severities() {
        return VulnerabilitiesParser.countBySeverities(this.vulnerabilities);
      },

      highestSeverity() {
        const severitiesKeys = Object.keys(this.severities);

        return severitiesKeys.reduce((a, b) => {
          if (this.severities[a] > 0) {
            return a;
          }

          return b;
        });
      },

      highestSeverityNumber() {
        return this.severities[this.highestSeverity];
      },

      total() {
        return this.vulnerabilities.length;
      },
    },
  };
</script>
