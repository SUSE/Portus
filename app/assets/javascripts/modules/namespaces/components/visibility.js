import Vue from 'vue';

import NamespacesService from '../services/namespaces';

const { set } = Vue;

export default {
  template: '#js-namespace-visibility-tmpl',

  props: ['namespace'],

  data() {
    return {
      onGoingRequest: false,
      newVisibility: null,
    };
  },

  computed: {
    isPrivate() {
      return this.namespace.visibility === 'private';
    },

    isProtected() {
      return this.namespace.visibility === 'protected';
    },

    isPublic() {
      return this.namespace.visibility === 'public';
    },

    canChangeVibisility() {
      return this.namespace.permissions.visibility &&
        !this.onGoingRequest;
    },

    privateTitle() {
      if (this.namespace.global) {
        return 'The global namespace cannot be private';
      }

      return 'Team members can pull images from this namespace';
    },
  },

  methods: {
    showLoading(visibility) {
      return this.onGoingRequest &&
        visibility === this.newVisibility;
    },

    change(visibility) {
      const currentVisibility = this.namespace.visibility;

      if (visibility === currentVisibility) {
        return;
      }

      set(this, 'onGoingRequest', true);
      set(this, 'newVisibility', visibility);

      NamespacesService.changeVisibility(this.namespace.id, { visibility }).then(() => {
        set(this.namespace, 'visibility', visibility);
        this.$alert.$show(`Visibility of '${this.namespace.name}' namespace updated`);
      }).catch(() => {
        this.$alert.$show('An error happened while updating namespace visibility');
      }).finally(() => {
        set(this, 'onGoingRequest', false);
        set(this, 'newVisibility', null);
      });
    },
  },
};
