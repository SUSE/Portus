import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

Vue.http.interceptors.push((request, next) => {
  if ($.rails) {
    console.log('add csrf token');
    // eslint-disable-next-line no-param-reassign
    request.headers['X-CSRF-Token'] = $.rails.csrfToken();
  }
  next();
});

Vue.config.productionTip = process.env.NODE_ENV !== 'production';
