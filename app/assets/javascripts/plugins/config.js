import config from '~/config';

export default function install(Vue) {
  Object.defineProperties(Vue.prototype, {
    $config: {
      get() {
        return config;
      },
    },
  });
}
