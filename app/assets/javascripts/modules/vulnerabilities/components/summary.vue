<template>
  <div class="vulnerabilities-summary">
    <p class="highlight" v-if="vulnerabilities.length > 0">We have detected <strong>{{ vulnerabilities.length }}</strong> vulnerabilities:</p>
    <p class="highlight" v-else>We have detected no vulnerabilities on this tag.</p>

    <ul class="list" v-if="vulnerabilities.length > 0">
      <li v-for="(count, severity) in severities" :key="severity" :class="severityClass(severity)" v-if="count > 0">
        <i class="fa fa-warning"></i> <strong>{{ count }}</strong> {{ severity }}-level vulnerabilities
      </li>
    </ul>
  </div>
</template>

<script>
  import VulnerabilitiesParser from '~/modules/repositories/services/vulnerabilities-parser';

  export default {
    props: ['vulnerabilities'],

    computed: {
      severityClass() {
        return severity => `severity-${severity.toLowerCase()}`;
      },

      severities() {
        return VulnerabilitiesParser.countBySeverities(this.vulnerabilities);
      },
    },
  };
</script>
