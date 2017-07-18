<style scoped>
  .selected td {
    background-color: #e8f1f6;
  }
</style>

<template>
  <tr :class="{ 'selected': selected }">
    <td v-if="canDestroy">
      <input type="checkbox" v-model="selected" @change="toggleTag()">
    </td>
    <td>
      <div class="label label-success" v-for="t in tag">{{ t.name }}</div>
    </td>

    <td>{{ tag[0].author.username }}</td>

    <td>
      <span v-if="tag[0].image_id === ''">-</span>
      <span v-else :title="prettyFormatID">
        {{ shortFormatID }}
      </span>
    </td>

    <td>{{ tag[0].updated_at }}</td>

    <td v-if="securityEnabled">
      <a :href="tagLink">
        {{ vulns }} vulnerabilities
      </a>
    </td>
  </tr>
</template>

<script>
  import VulnerabilitiesParser from '../services/vulnerabilities-parser';

  export default {
    props: {
      tag: [Array],
      canDestroy: Boolean,
      securityEnabled: Boolean,
      state: Object,
    },

    data() {
      return {
        tagsPath: '/tags',
        prefixID: 'sha256:',
        selected: false,
      };
    },

    computed: {
      prettyFormatID() {
        return `${this.prefixID}${this.tag[0].image_id}`;
      },

      shortFormatID() {
        return this.tag[0].image_id.substring(0, 12);
      },

      tagLink() {
        return `${this.tagsPath}/${this.tag[0].id}`;
      },

      vulns() {
        const vulns = VulnerabilitiesParser.parse(this.tag[0].vulnerabilities);

        // TODO: proper doughnut chart
        // https://github.com/apertureless/vue-chartjs
        return vulns.total;
      },
    },

    methods: {
      deselectTag() {
        this.tag.forEach((t) => {
          const index = this.state.selectedTags.findIndex(s => s.id === t.id);

          if (index !== -1) {
            this.state.selectedTags.splice(index, 1);
          }
        });
      },

      selectTag() {
        this.state.selectedTags.push({
          id: this.tag[0].id,
          name: this.tag.map(t => t.name).join(', '),
          multiple: this.tag.length > 1,
        });
      },

      toggleTag() {
        if (this.selected) {
          this.selectTag();
        } else {
          this.deselectTag();
        }
      },
    },
  };
</script>
