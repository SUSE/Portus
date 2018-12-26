<template>
  <tbody>
    <tr>
      <td class="col-caret">
        <span @click="toggleDetails" data-placement="top" title="View details" class="has-tooltip toggle-details"><i class="fa" :class="caretClass"></i></span>
      </td>
      <td>
        {{ vulnerability.name }}
        <a :href="vulnerability.link" v-if="vulnerability.link" target="_blank"><i class="fa fa-link"></i></a>
      </td>
      <td :class="severityClass">
        <i class="fa fa-warning"></i> {{ vulnerability.severity }}
      </td>
      <td>{{ scannerCapitalized }}</td>
    </tr>

    <tr class="vulnerability-details" v-show="expanded">
      <td colspan="4">
        <div>
          <h5 class="title">Description</h5>
          <p class="description" v-if="vulnerability.description">{{ vulnerability.description }}</p>
          <p class="description" v-else>No description provided.</p>
        </div>
      </td>
    </tr>
  </tbody>
</template>

<script>
  import Vue from 'vue';

  const { set } = Vue;

  export default {
    props: ['vulnerability'],

    data() {
      return {
        expanded: false,
      };
    },

    computed: {
      caretClass() {
        if (this.expanded) {
          return 'fa-caret-down';
        }

        return 'fa-caret-right';
      },

      severityClass() {
        return `severity-${this.vulnerability.severity.toLowerCase()}`;
      },

      metadata() {
        return JSON.parse(this.vulnerability.metadata);
      },

      scannerCapitalized() {
        const { scanner } = this.vulnerability;

        return scanner.charAt(0).toUpperCase() + scanner.substr(1);
      },
    },

    methods: {
      toggleDetails() {
        set(this, 'expanded', !this.expanded);
      },
    },
  };
</script>
