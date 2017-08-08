import Vue from 'vue';

import Alert from '~/shared/components/alert';

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
      return this.namespace.attributes.visibility === 'visibility_private';
    },

    isProtected() {
      return this.namespace.attributes.visibility === 'visibility_protected';
    },

    isPublic() {
      return this.namespace.attributes.visibility === 'visibility_public';
    },

    canChangeVibisility() {
      return this.namespace.meta.can_change_visibility &&
        !this.onGoingRequest;
    },

    privateTitle() {
      if (this.namespace.attributes.global) {
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
      const currentVisibility = this.namespace.attributes.visibility;

      if (visibility === currentVisibility) {
        return;
      }

      set(this, 'onGoingRequest', true);
      set(this, 'newVisibility', visibility);

      NamespacesService.changeVisibility(this.namespace.id, { visibility }).then(() => {
        set(this.namespace.attributes, 'visibility', visibility);
        Alert.show(`Visibility of '${this.namespace.attributes.clean_name}' namespace updated`);
      }).catch(() => {
        Alert.show('An error happened while updating namespace visibility');
      }).finally(() => {
        set(this, 'onGoingRequest', false);
        set(this, 'newVisibility', null);
      });
    },
  },
};
