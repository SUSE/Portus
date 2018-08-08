import Alert from '~/utils/alert';

export default function install(Vue) {
  Object.defineProperties(Vue.prototype, {
    $alert: {
      get() {
        return Alert;
      },
    },
  });
}
