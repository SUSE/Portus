import Vue from 'vue';
import VueResource from 'vue-resource';
import Vuelidate from 'vuelidate';

import EventBus from './plugins/eventbus';
import Alert from './plugins/alert';

Vue.use(Vuelidate);
Vue.use(VueResource);
Vue.use(EventBus);
Vue.use(Alert);

Vue.http.options.root = window.API_URL;

Vue.http.interceptors.push((_request, next) => {
  window.$.active = window.$.active || 0;
  window.$.active += 1;

  next(() => {
    window.$.active -= 1;
  });
});

Vue.http.interceptors.push((request, next) => {
  if ($.rails) {
    // eslint-disable-next-line no-param-reassign
    request.headers.set('X-CSRF-Token', $.rails.csrfToken());
  }
  next();
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
