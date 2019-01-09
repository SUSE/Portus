<style scoped>
  .selected td {
    background-color: #e8f1f6;
  }

  .vulns-link {
    text-decoration: none;
  }
</style>

<template>
  <tr :class="{ 'selected': selected }">
    <td v-if="canDestroy">
      <checkbox v-model="selected" @change="toggleTag()"></checkbox>
    </td>

    <td>
      <tag v-for="t in tag" :key="t.name" :tag="t" :repository="repository"></tag>
    </td>

    <td>{{ tag[0].author.name }}</td>

    <td class="image-id text-monospace">
      <span v-if="tag[0].image_id === ''">-</span>
      <span v-else :title="tag[0].digest">
        {{ shortFormatID }}
      </span>
    </td>

    <td>
      {{ size }}
    </td>

    <td>
      <span data-placement="top" :title="pushedAtFull" class="has-tooltip">
        {{ pushedAt }}
      </span>
    </td>

    <td class="vulns" v-if="securityEnabled">
      <span v-if="scanPending">Pending</span>
      <span v-if="scanInProgress">In progress</span>
      <a :href="tagLink" v-if="scanDone" class="vulns-link" title="Click for details">
        <vulnerabilities-preview :vulnerabilities="this.tag[0].vulnerabilities"></vulnerabilities-preview>
      </a>
    </td>
  </tr>
</template>

<script>
  import dayjs from 'dayjs';

  import Tag from './tag';
  import VulnerabilitiesPreview from '~/modules/vulnerabilities/components/preview';
  import Checkbox from '~/shared/components/checkbox';

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
      Checkbox,
      VulnerabilitiesPreview,
    },

    data() {
      return {
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

      shortFormatID() {
        if (this.tag[0].image_id) {
          return this.tag[0].image_id.substring(0, 12);
        }

        return '';
      },

      tagLink() {
        return `${this.tagsPath}/${this.tag[0].id}`;
      },

      pushedAt() {
        return dayjs(this.tag[0].updated_at).fromNow();
      },

      pushedAtFull() {
        return dayjs(this.tag[0].updated_at).format('MMMM DD, YYYY hh:mm A');
      },

      size() {
        if (this.tag[0].size_human) {
          return this.tag[0].size_human;
        }
        return '-';
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
