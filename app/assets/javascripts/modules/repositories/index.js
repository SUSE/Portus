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
      var total = 0; // TODO: remove once we do this properly

      AVAILABLE_BACKENDS.forEach((backend) => {
        if (!tag.vulnerabilities[backend]) {
          return;
        }

        tag.vulnerabilities[backend].forEach((vul) => {
          result[vul["Severity"]] += 1;
          total += 1;
        });
      });

      // TODO: proper doughnut chart
      // https://github.com/apertureless/vue-chartjs
      return `${total} vulnerabilities`;
    },

    toggleDelete: function(_event) {
      if (!this.deletable) {
        return;
      }

      if ($("#tags-table tr input:checkbox:checked").length > 0) {
        $(DELETE_TAG_ELEMENT).removeClass("hidden");
      } else {
        if (!$(DELETE_TAG_ELEMENT).hasClass("hidden")) {
          $(DELETE_TAG_ELEMENT).addClass("hidden");
        }
      }
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

  $("#actions-toolbar .delete button").click((e) => {
    $("#tags-table tr input:checkbox:checked").map((_, element) => {
      var id = element.value;

      Vue.http.delete(`/tags/${id}`).then(response => {
        console.log(response);
      }, response => {
        // TODO: treat errors better
        console.log("delete failed");
      });
    });
  });
});
