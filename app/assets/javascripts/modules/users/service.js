import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const customActions = {
  createToken: {
    method: 'POST',
    url: 'api/v1/users/{userId}/application_tokens',
  },
  destroyToken: {
    method: 'DELETE',
    url: 'api/v1/users/application_tokens/{id}',
  },
};

const resource = Vue.resource('api/v1/users{/id}', {}, customActions);

function createToken(userId, appToken) {
  return resource.createToken({ userId }, appToken);
}

function destroyToken(id) {
  return resource.destroyToken({ id });
}

export default {
  createToken,
  destroyToken,
};
