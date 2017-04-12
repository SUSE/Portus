import Vue from 'vue';
import VueResource from 'vue-resource';

Vue.use(VueResource);

Vue.http.interceptors.push((request, next) => {
  if ($.rails) {
    console.log("here");
    console.log($.rails.csrfToken());
    // eslint-disable-next-line no-param-reassign
    request.headers['X-CSRF-Token'] = $.rails.csrfToken();
  }
  next();
});

if (process.env.NODE_ENV !== 'production') {
  Vue.config.productionTip = false;
}
