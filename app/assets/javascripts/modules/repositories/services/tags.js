import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const oldResource = Vue.resource('tags{/id}.json');

function remove(id) {
  return oldResource.delete({ id });
}

export default {
  remove,
};
