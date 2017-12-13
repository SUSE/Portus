import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const customActions = {
  teamTypeahead: {
    method: 'GET',
    url: 'teams/typeahead/{teamName}',
  },
};

const resource = Vue.resource('api/v1/teams{/id}{?hidden}', {}, customActions);

function all(params = {}) {
  return resource.get({}, params);
}

function get(id) {
  return resource.get({ id });
}

function save(team) {
  return resource.save({}, team);
}

function searchTeam(teamName, options = {}) {
  const params = Object.assign({ teamName }, options);

  return resource.teamTypeahead(params);
}

function exists(value, options) {
  return searchTeam(value, options)
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
  exists,
};
