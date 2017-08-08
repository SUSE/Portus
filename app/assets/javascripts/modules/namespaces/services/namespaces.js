import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const customActions = {
  changeVisibility: {
    method: 'PUT',
    url: '/namespaces/{id}/change_visibility',
  },
};

const resource = Vue.resource('/namespaces{/id}.json', {}, customActions);

function all(params = {}) {
  return resource.get({}, params);
}

function changeVisibility(id, params = {}) {
  return resource.changeVisibility({ id }, params);
}

function get(id) {
  return resource.get({ id });
}

function save(namespace) {
  return resource.save({}, namespace);
}

export default {
  get,
  all,
  save,
  changeVisibility,
};
