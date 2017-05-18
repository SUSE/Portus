import Vue from 'vue';

import LoadingIcon from '~/shared/components/loading-icon';
import Alert from '~/shared/components/alert';
import EventBus from '~/utils/eventbus';

import TagsTable from '../components/tags-table';
import TagsNotLoaded from '../components/tags-not-loaded';
import DeleteTagAction from '../components/delete-tag-action';

import RepositoriesService from '../services/repositories';
import TagsService from '../services/tags';

import RepositoriesStore from '../store';

// eslint-disable-next-line
import '~/vue-shared';

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
      DeleteTagAction,
    },

    data() {
      const store = new RepositoriesStore();

      return {
        state: store.state,
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
          // setTimeout(() => this.loadData(), POLLING_VALUE);
          set(this, 'isLoading', false);
        });
      },

      removeFromCollection(tagId) {
        const newTags = this.tags.filter(tag => !tag.find(t => t.id === tagId));

        set(this, 'tags', newTags);
      },

      removeFromSelection(tagId) {
        const index = this.tags.findIndex(t => t.id === tagId);

        this.state.selectedTags.splice(index, 1);
      },

      deleteTags() {
        const success = [];

        const promises = this.state.selectedTags.map((t) => {
          return TagsService.remove(t.id).then(() => {
            this.removeFromCollection(t.id);
            this.removeFromSelection(t.id);
            success.push(t.id);
          });
        });

        Promise.all(promises).then(() => {
          Alert.show('Tags removed successfully!');
        }).catch(() => {
          console.log('something failed');
          console.log('removed', success);
        });
      },
    },

    mounted() {
      set(this, 'isLoading', true);
      this.loadData();
      EventBus.$on('deleteTags', () => this.deleteTags());
    },
  });
});
