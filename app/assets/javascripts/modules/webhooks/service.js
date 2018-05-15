import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const customActions = {
  toggleEnabled: {
    method: 'PUT',
    url: 'namespaces/{namespaceId}/webhooks/{id}/toggle_enabled.json',
  },
};

const oldResource = Vue.resource('namespaces/{namespaceId}/webhooks{/id}.json', {}, customActions);

function destroy(namespaceId, id) {
  return oldResource.delete({ namespaceId, id });
}

function save(namespaceId, webhook) {
  return oldResource.save({ namespaceId }, { webhook });
}

function toggleEnabled(namespaceId, id) {
  return oldResource.toggleEnabled({ namespaceId, id }, {});
}

export default {
  destroy,
  save,
  toggleEnabled,
};
