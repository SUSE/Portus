import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

const oldResource = Vue.resource('namespaces/{namespaceId}/webhooks/{webhookId}/deliveries{/id}.json');

function retrigger(namespaceId, webhookId, id) {
  return oldResource.update({ namespaceId, webhookId, id }, {});
}

export default {
  retrigger,
};
