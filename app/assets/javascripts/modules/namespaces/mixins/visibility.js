export default {
  props: ['namespace'],

  data() {
    return {
      onGoingRequest: false,
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
      return this.namespace.permissions.visibility
          && !this.onGoingRequest;
    },

    privateTitle() {
      if (this.namespace.global) {
        return 'The global namespace cannot be private';
      }

      return 'Team members can pull images from this namespace';
    },
  },
};
