import Vue from 'vue';
import VueResource from 'vue-resource';
import Vuelidate from 'vuelidate';

import EventBus from '~/plugins/eventbus';
import Alert from '~/plugins/alert';
import Config from '~/plugins/config';

import CSRF from '~/utils/csrf';

import configObj from '~/config';

Vue.use(Vuelidate);
Vue.use(VueResource);
Vue.use(EventBus);
Vue.use(Alert);
Vue.use(Config);

Vue.http.options.root = configObj.apiUrl;

Vue.http.interceptors.push((_request) => {
  window.$.active = window.$.active || 0;
  window.$.active += 1;

  return function () {
    window.$.active -= 1;
  };
});

Vue.http.interceptors.push((request) => {
  const token = CSRF.token();

  if (token !== null) {
    request.headers.set('X-CSRF-Token', token);
  }
});
