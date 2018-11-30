import Vue from 'vue';
import VueMultiselect from 'vue-multiselect';

import NamespacesService from '../services/namespaces';

const { set } = Vue;

export default {
  components: {
    VueMultiselect,
  },

  data() {
    return {
      mixinAttr: 'namespace',
      teams: [],
      selectedTeam: null,
      isLoading: false,
    };
  },

  methods: {
    searchTeam(query) {
      if (!query) {
        return;
      }

      set(this, 'isLoading', true);
      NamespacesService.searchTeam(query).then((response) => {
        set(this, 'teams', response.data);
      }).catch(() => {
        void 0;
      }).finally(() => set(this, 'isLoading', false));
    },

    onSelect(team) {
      set(this[this.mixinAttr], 'team', team.name);
    },

    onRemove() {
      set(this[this.mixinAttr], 'team', '');
    },

    onTouch() {
      this.$v[this.mixinAttr].team.$touch();
    },
  },
};
