import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const resource = Vue.resource('/repositories{/id}.json');

function get(id) {
  return resource.get({ id });
}

export default {
  get,
};
