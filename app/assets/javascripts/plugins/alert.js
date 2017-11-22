import Alert from '~/shared/components/alert';

export default function install(Vue) {
  Object.defineProperties(Vue.prototype, {
    $alert: {
      get() {
        return Alert;
      },
    },
  });
}
