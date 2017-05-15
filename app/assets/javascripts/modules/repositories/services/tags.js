import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const resource = Vue.resource('/tags/{/id}.json');

function remove(id) {
  return resource.delete({ id });
}

export default {
  remove,
};
