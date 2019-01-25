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

const oldCustomActions = {
  toggleAdmin: {
    method: 'PUT',
    url: 'admin/users/{id}/toggle_admin',
  },
  toggleEnabled: {
    method: 'PUT',
    url: 'toggle_enabled/{id}',
  },
};

const resource = Vue.resource('api/v1/users{/id}', {}, customActions);
const oldResource = Vue.resource('admin/users{/id}', {}, oldCustomActions);

function createToken(userId, appToken) {
  return resource.createToken({ userId }, appToken);
}

function destroyToken(id) {
  return resource.destroyToken({ id });
}

function save(user) {
  return oldResource.save({}, { user });
}

function update(user) {
  return resource.update({ id: user.id }, { user });
}

function destroy({ id }) {
  return resource.delete({ id });
}

function toggleAdmin({ id }) {
  return oldResource.toggleAdmin({ id }, {});
}

function toggleEnabled({ id }) {
  return oldResource.toggleEnabled({ id }, {});
}

export default {
  save,
  destroy,
  update,
  toggleAdmin,
  toggleEnabled,
  createToken,
  destroyToken,
};
