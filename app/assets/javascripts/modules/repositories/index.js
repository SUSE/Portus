import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const POLLING_VALUE = 5000;
const DELETE_TAG_ELEMENT = "#actions-toolbar .delete";
const AVAILABLE_BACKENDS = ["clair", "zypper", "dummy"];

Vue.component('tag-row', {
  template: '#tag-row',
  props: ['tag'],

  data: function(){
    return {
      deletable: $(DELETE_TAG_ELEMENT).length > 0,
    }
  },

  methods: {
    // Returns the image ID of the given tag in a pretty format.
    prettyFormat: function(tag) {
      return `sha256:${tag.image_id}`;
    },

    // Returns the image ID of the given tag in a short format.
    shortFormat: function(tag) {
      return tag.image_id.substring(0, 12);
    },

    tagLink: function(tag) {
      return `/tags/${tag.id}`;
    },

    vulns: function(tag) {
      var result = {"High": 0, "Normal": 0, "Low": 0};

      AVAILABLE_BACKENDS.forEach((backend) => {
        if (!tag.vulnerabilities[backend]) {
          return;
        }

        tag.vulnerabilities[backend].forEach((vul) => {
          result[vul["Severity"]] += 1;
        });
      });

      // TODO: proper doughnut chart
      // https://github.com/apertureless/vue-chartjs
      var total = result["High"] + result["Normal"] + result["Low"];
      return `${total} vulnerabilities`;
    },
  },
})

// TODO: handle better the "Loading..." part
$(() => {
  new Vue({
    el: '#tags-table',
    data: {
      tags: [],
    },

    methods: {
      loadData: function () {
        var id = $("#repo-name").data('id');

        Vue.http.get('/repositories/' + id + '.json').then(response => {
          Vue.set(this, 'tags', response.body.tags);
        }, response => {
          // TODO: treat errors better
          console.log("oops");
        });
      }
    },

    mounted: function () {
      this.loadData();
      setInterval(function () { this.loadData() }.bind(this), POLLING_VALUE);
    },
  });
});
