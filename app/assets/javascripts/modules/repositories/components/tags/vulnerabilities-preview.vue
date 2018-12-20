<style scoped>
  .critical .highlight,
  .defcon1 .highlight {
    color: #B9121B;
  }

  .high .highlight {
    color: #FF5E38;
  }

  .medium .highlight {
    color: #f28c33;
  }

  .low .highlight {
    color: #f8ca1c;
  }

  .unknown .highlight {
    color: #5b5b5b;
  }

  .passed {
    color: #5cb85c;
  }
</style>

<template>
  <span>
    <span v-if="total > 0" :class="highestSeverity.toLowerCase()">
      <span class="highlight"><i class="fa fa-warning"></i> {{ highestSeverityNumber }} {{ highestSeverity }}</span> - <span class="total">{{ total }} total</span>
    </span>
    <span v-else class="passed">
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
      severities() {
        return VulnerabilitiesParser.countBySeverities(this.vulnerabilities);
      },

      highestSeverity() {
        const severitiesKeys = Object.keys(this.severities);

        return severitiesKeys.reduce((a, b) => {
          if (this.severities[b] > 0) {
            return b;
          }

          return a;
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
