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

const { set } = Vue;

const POLLING_VALUE = 10000;

$(() => {
  if (!$('body[data-route="repositories/show"]').length) {
    return;
  }

  // eslint-disable-next-line
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
          setTimeout(() => this.loadData(), POLLING_VALUE);
          set(this, 'isLoading', false);
        });
      },

      removeFromCollection(tagId) {
        const newTags = this.tags.filter(tag => !tag.some(t => t.id === tagId));

        set(this, 'tags', newTags);
      },

      removeFromSelection(tagId) {
        const index = this.tags.findIndex(t => t.id === tagId);

        this.state.selectedTags.splice(index, 1);
      },

      deleteTags() {
        const success = [];
        const failure = [];
        const total = this.state.selectedTags.length;
        let promiseCount = 0;

        const showAlert = (count) => {
          if (count === total) {
            let message = '';

            if (success.length) {
              message += `<strong>${success.join(', ')}</strong> successfully removed. <br />`;
            }
            if (failure.length) {
              message += `<strong>${failure.join(', ')}</strong> unable to be removed.`;
            }

            Alert.show(message);

            if (!this.tags.length) {
              const namespaceHref = this.$refs.repoLink.querySelector('a').href;
              window.location.href = namespaceHref;
            }
          }
        };

        this.state.selectedTags.forEach((t) => {
          TagsService.remove(t.id).then(() => {
            this.removeFromCollection(t.id);
            this.removeFromSelection(t.id);
            success.push(t.name);
          }).catch(() => {
            failure.push(t.name);
          }).finally(() => showAlert(++promiseCount));
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
