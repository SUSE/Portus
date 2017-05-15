import Vue from 'vue';
import VueResource from 'vue-resource';

import LoadingIcon from '~/shared/components/loading-icon';
import Alert from '~/shared/components/alert';

import TagsTable from '../components/tags-table';
import TagsNotLoaded from '../components/tags-not-loaded';

import RepositoriesService from '../services/repositories';
import TagsService from '../services/tags';

Vue.use(VueResource);

const { set } = Vue;

const POLLING_VALUE = 10000;

$(() => {
  if (!$('body[data-route="repositories/show"]').length) {
    return;
  }

  new Vue({
    el: 'body[data-route="repositories/show"] .vue-root',

    components: {
      LoadingIcon,
      TagsTable,
      TagsNotLoaded,
    },

    data() {
      return {
        isLoading: false,
        notLoaded: false,
        tags: [],
      };
    },

    methods: {
      loadData() {
        const id = this.$refs.repoLink.dataset.id;

        RepositoriesService.get(id).then((response) => {
          set(this, 'tags', response.body.tags);
          set(this, 'notLoaded', false);
        }, () => {
          // if the data never came,
          // show message instead of table,
          // otherwise only the alert
          if (this.isLoading) {
            set(this, 'notLoaded', true);
          } else {
            Alert.show('Unable to fetch newer tags data');
          }
        }).finally(() => {
          setTimeout(() => this.loadData(), POLLING_VALUE);
          set(this, 'isLoading', false);
        });
      },
    },

    mounted() {
      set(this, 'isLoading', true);
      this.loadData();
    },
  });

  $('#actions-toolbar .delete button').click(() => {
    $('#tags-table tr input:checkbox:checked').map((_, element) => {
      const id = element.value;

      TagsService.remove(id).then((response) => {
        console.log(response);
      }, () => {
        // TODO: treat errors better
        console.log('delete failed');
      });
    });
  });
});
