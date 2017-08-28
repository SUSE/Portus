import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const customActions = {
  validate: {
    method: 'GET',
    url: 'api/v1/registries/validate',
  },
};

const resource = Vue.resource('api/v1/registries/{/id}.json', {}, customActions);

function validate(registry, field = null) {
  const data = registry;

  if (field) {
    data['only[]'] = field;
  }

  return resource.validate(data)
    .then(response => response.data)
    .catch(() => null);
}

export default {
  validate,
};
