import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const tagsCustomActions = {
  groupedTags: {
    method: 'GET',
    url: 'api/v1/repositories/{repositoryId}/tags/grouped',
  },
};

const resource = Vue.resource('api/v1/repositories{/id}');
const tagsResource = Vue.resource('api/v1/repositories{/repositoryId}/tags', {}, tagsCustomActions);

function get(id) {
  return resource.get({ id });
}

function remove(id) {
  return resource.delete({ id });
}

function groupedTags(repositoryId) {
  return tagsResource.groupedTags({ repositoryId });
}

export default {
  get,
  groupedTags,
  remove,
};
