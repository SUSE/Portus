import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

Vue.component('tag-row', {
  template: '#tag-row',
  props: ['tag'],

  //data: function() {
    // TODO
    //return {
      //deletable: false,
      //has_digest: false,
      //errors: {}
    //}
  //},
})

$(() => {
  var tags = new Vue({
    el: '#tags-table',
    data: {
      tags: [],
      tag: {},
      errors: {}
    },

    methods: {
      loadData: function () {
        var id = $("#repo-name").data('id');

        Vue.http.get('/repositories/' + id + '.json').then(response => {
          // TODO: do something clever with this
          this.tags = response.body.tags;
          console.log(this.tags);
          console.log(JSON.stringify(this.tags));
        }, response => {
          // TODO: treat errors better
          console.log("oops");
        });
      }
    },

    mounted: function () {
      this.loadData();
      //console.log(this.tags);

      setInterval(function () {
        this.loadData();
      }.bind(this), 5000); // TODO: change number
    },
  });
});
