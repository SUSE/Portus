import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const customActions = {
  teamTypeahead: {
    method: 'GET',
    url: '/namespaces/typeahead/{teamName}',
  },
  existsByName: {
    method: 'HEAD',
    url: '/namespaces',
  },
};

const oldCustomActions = {
  changeVisibility: {
    method: 'PUT',
    url: '/namespaces/{id}/change_visibility',
  },
};

const oldResource = Vue.resource('namespaces{/id}.json', {}, oldCustomActions);
const resource = Vue.resource('api/v1/namespaces{/id}', {}, customActions);

function all(params = {}) {
  return resource.get({}, params);
}

function changeVisibility(id, params = {}) {
  return oldResource.changeVisibility({ id }, params);
}

function searchTeam(teamName) {
  return resource.teamTypeahead({ teamName });
}

function existsByName(name) {
  return resource.existsByName({ name })
    .then(() => true)
    .catch((response) => {
      if (response.status === 404) {
        return false;
      }

      return null;
    });
}

function get(id) {
  return resource.get({ id });
}

function save(namespace) {
  return oldResource.save({}, namespace);
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

export default {
  get,
  all,
  save,
  changeVisibility,
  searchTeam,
  teamExists,
  existsByName,
};
