import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

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

Vue.config.productionTip = process.env.NODE_ENV !== 'production';
