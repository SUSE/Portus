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
      <tag v-for="t in tag" :key="t.name" :tag="t" :repository="repository"></tag>
    </td>

    <td>{{ tag[0].author.name }}</td>

    <td class="image-id">
      <span v-if="tag[0].image_id === ''">-</span>
      <span v-else :title="prettyFormatID">
        {{ shortFormatID }}
      </span>
    </td>

    <td>{{ pushedAt }}</td>

    <td class="vulns" v-if="securityEnabled">
      <span v-if="scanPending">Pending</span>
      <span v-if="scanInProgress">In progress</span>
      <a :href="tagLink" v-if="scanDone">
        {{ vulns }} vulnerabilities
      </a>
    </td>
  </tr>
</template>

<script>
  import dayjs from 'dayjs';

  import Tag from './tag';

  import VulnerabilitiesParser from '../../services/vulnerabilities-parser';

  const NOT_SCANNED = 0;
  const SCAN_DONE = 2;
  const SCAN_IN_PROGRESS = 1;

  export default {
    props: {
      tag: [Array],
      canDestroy: Boolean,
      securityEnabled: Boolean,
      state: Object,
      tagsPath: String,
      repository: Object,
    },

    components: {
      Tag,
    },

    data() {
      return {
        prefixID: 'sha256:',
        selected: false,
      };
    },

    computed: {
      scanPending() {
        return this.tag[0].scanned === NOT_SCANNED;
      },

      scanInProgress() {
        return this.tag[0].scanned === SCAN_IN_PROGRESS;
      },

      scanDone() {
        return this.tag[0].scanned === SCAN_DONE;
      },

      prettyFormatID() {
        return `${this.prefixID}${this.tag[0].image_id}`;
      },

      shortFormatID() {
        if (this.tag[0].image_id) {
          return this.tag[0].image_id.substring(0, 12);
        }

        return '';
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

      pushedAt() {
        return dayjs(this.tag[0].updated_at).format('MMMM DD, YYYY HH:mm');
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
