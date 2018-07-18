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

// we are not a SPA and when user clicks on back/forward
// we want the page to be fully reloaded to take advantage of
// the url query params state
window.onpopstate = function (e) {
  // phantomjs seems to trigger an oppopstate event
  // when visiting pages, e.state is always null and
  // in our component we set an empty string
  if (e.state !== null) {
    window.location.reload();
  }
};

Vue.config.productionTip = process.env.NODE_ENV !== 'production';
