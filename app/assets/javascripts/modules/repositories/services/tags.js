import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const resource = Vue.resource('api/v1/tags{/id}');

function remove(id) {
  return resource.delete({ id });
}

export default {
  remove,
};
