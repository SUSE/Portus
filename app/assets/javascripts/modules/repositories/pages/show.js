import Vue from 'vue';

import { handleHttpResponseError } from '~/utils/http';

import LoadingIcon from '~/shared/components/loading-icon';

import TagsTable from '../components/tags-table';
import TagsNotLoaded from '../components/tags-not-loaded';
import DeleteTagAction from '../components/delete-tag-action';
import CommentsWrapper from '../components/comments/wrapper';

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
      CommentsWrapper,
    },

    data() {
      const store = new RepositoriesStore();

      return {
        state: store.state,
        isDeleting: false,
        isLoading: true,
        notLoaded: false,
        unableToFetchBefore: false,
        tags: [],
      };
    },

    methods: {
      loadData() {
        const id = this.$refs.repoTitle.dataset.id;

        RepositoriesService.get(id).then((response) => {
          set(this.state, 'repository', response.body);
        });

        this.fetchTags();
      },

      fetchTags() {
        const repositoryId = this.$refs.repoTitle.dataset.id;

        if (this.state.isDeleting) {
          setTimeout(() => this.fetchTags(), POLLING_VALUE);
          return;
        }

        RepositoriesService.groupedTags(repositoryId).then((response) => {
          set(this, 'tags', response.body);
          set(this, 'notLoaded', false);
          set(this, 'unableToFetchBefore', false);
        }, () => {
          // if the data never came,
          // show message instead of table,
          // otherwise only the alert
          if (this.isLoading) {
            set(this, 'notLoaded', true);
          }

          if (!this.isLoading && !this.unableToFetchBefore) {
            this.$alert.$show('Unable to fetch newer tags data');
            set(this, 'unableToFetchBefore', true);
          }
        }).finally(() => {
          setTimeout(() => this.fetchTags(), POLLING_VALUE);
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

            this.$alert.$show(message);

            if (!this.tags.length) {
              const namespaceHref = this.$refs.repoLink.href;

              this.$alert.$schedule('Repository removed with all its tags.');
              window.location.href = namespaceHref;
            }
          }
        };

        this.state.selectedTags.forEach((t) => {
          set(this.state, 'isDeleting', true);

          TagsService.remove(t.id).then(() => {
            this.removeFromCollection(t.id);
            this.removeFromSelection(t.id);
            success.push(t.name);
          }).catch(() => {
            failure.push(t.name);
          }).finally(() => {
            set(this.state, 'isDeleting', false);
            showAlert(++promiseCount);
          });
        });
      },

      deleteRepository() {
        set(this.state, 'isDeleting', true);

        RepositoriesService.remove(this.state.repository.id).then(() => {
          const namespaceHref = this.$refs.repoLink.href;

          this.$alert.$schedule('Repository removed with all its tags');
          window.location.href = namespaceHref;
        }).catch(handleHttpResponseError)
          .finally(() => set(this.state, 'isDeleting', false));
      },
    },

    mounted() {
      const DELETE_BTN = '.repository-delete-btn';
      const POPOVER_DELETE = '.popover-repository-delete';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', DELETE_BTN, () => {
        const $yes = $(POPOVER_DELETE).find('.yes');
        $yes.click(this.deleteRepository.bind(this));
      });

      this.loadData();
      this.$bus.$on('deleteTags', () => this.deleteTags());
    },
  });
});
