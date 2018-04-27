import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const oldResource = Vue.resource('repositories/{repositoryId}/comments{/id}.json');

function save(repositoryId, comment) {
  return oldResource.save({ repositoryId }, { comment });
}

function remove(repositoryId, id) {
  return oldResource.delete({ repositoryId, id });
}

export default {
  save,
  remove,
};
