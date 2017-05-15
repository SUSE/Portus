const DELETE_TAG_ELEMENT = '#actions-toolbar .delete';
const AVAILABLE_BACKENDS = ['clair', 'zypper', 'dummy'];

export default {
  template: `
    <tr>
      <td>
        <input type="checkbox" class="option-tag" @click="toggleDelete()" v-if="deletable"  :value="tag[0].id" >
        <div class="label label-success" v-for="t in tag">
          {{ t.name }}
        </div>
      </td>

      <td>{{ tag[0].author.username }}</td>

      <td>
        <span v-if="tag[0].image_id === ''">-</span>
        <span v-else :title="prettyFormatID">
          {{ shortFormatID }}
        </span>
      </td>

      <td>{{ tag[0].updated_at }}</td>

      <td>
        <a :href="tagLink">
          {{ vulns }} vulnerabilities
        </a>
      </td>
    </tr>`,

  props: ['tag'],

  data() {
    return {
      deletable: $(DELETE_TAG_ELEMENT).length > 0,
      tagsPath: '/tags',
      prefixID: 'sha256:',
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
      return `${this.tagsPath}/${this.tag.id}`;
    },

    vulns() {
      const result = {
        High: 0,
        Normal: 0,
        Low: 0,
      };
      let total = 0; // TODO: remove once we do this properly

      if (this.tag.vulnerabilities) {
        AVAILABLE_BACKENDS.forEach((backend) => {
          if (!this.tag.vulnerabilities[backend]) {
            return;
          }

          this.tag.vulnerabilities[backend].forEach((vul) => {
            result[vul.Severity] += 1;
            total += 1;
          });
        });
      }

      // TODO: proper doughnut chart
      // https://github.com/apertureless/vue-chartjs
      return total;
    },
  },

  methods: {
    toggleDelete(_event) {
      if (!this.deletable) {
        return;
      }

      if ($('#tags-table tr input:checkbox:checked').length > 0) {
        $(DELETE_TAG_ELEMENT).removeClass('hidden');
      } else {
        if (!$(DELETE_TAG_ELEMENT).hasClass('hidden')) {
          $(DELETE_TAG_ELEMENT).addClass('hidden');
        }
      }
    },
  },
};
