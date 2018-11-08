import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const customActions = {
  teamTypeahead: {
    method: 'GET',
    url: 'namespaces/typeahead/{teamName}',
  },
  validate: {
    method: 'GET',
    url: 'api/v1/namespaces/validate',
  },
};

const resource = Vue.resource('api/v1/namespaces{/id}', {}, customActions);

function all(params = {}) {
  return resource.get(params);
}

function searchTeam(teamName) {
  return resource.teamTypeahead({ teamName });
}

function validate(name) {
  return resource.validate({ name })
    .then(response => response.data)
    .catch(() => null);
}

function get(id) {
  return resource.get({ id });
}

function save(namespace) {
  return resource.save({}, namespace);
}

function update(id, namespace) {
  return resource.update({ id }, namespace);
}

function teamExists(value) {
  return searchTeam(value)
    .then((response) => {
      const collection = response.data;

      if (Array.isArray(collection)) {
        return collection.some(e => e.name === value);
      }

      // some unexpected response from the api,
      // leave it for the back-end validation
      return null;
    })
    .catch(() => null);
}

function remove(id) {
  return resource.delete({ id });
}

export default {
  get,
  all,
  update,
  save,
  remove,
  searchTeam,
  teamExists,
  validate,
};
