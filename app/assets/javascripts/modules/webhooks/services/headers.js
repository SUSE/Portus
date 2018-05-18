import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const oldResource = Vue.resource('namespaces/{namespaceId}/webhooks/{webhookId}/headers{/id}.json');

function destroy(namespaceId, webhookId, id) {
  return oldResource.delete({ namespaceId, webhookId, id });
}

function save(namespaceId, webhookId, webhook_header) {
  return oldResource.save({ namespaceId, webhookId }, { webhook_header });
}

export default {
  destroy,
  save,
};
