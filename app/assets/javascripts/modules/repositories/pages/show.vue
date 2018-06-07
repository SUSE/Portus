<template>
  <div class="repositories-show-page">
    <div class="header clearfix">
      <h4 class="repository-title pull-left">
        <a href="javascript:void(0)"
          class="btn-link repository-information-icon"
          data-placement="right"
          data-toggle="popover"
          data-trigger="focus click hover"
          data-title="More information"
          :data-content="repositoryInformation"
          data-html="true">
          <i class="fa fa-info-circle"></i>
        </a>
        <a :href="namespacePath">{{ namespaceName }}</a>/{{ repository.name }}
      </h4>

      <div class="btn-toolbar pull-right">
        <star :repository="repository" @click.native.prevent="toggleStar"></star>
        <div class="btn-group" v-if="repository.destroyable">
          <button
            class="btn btn-danger repository-delete-btn"
            data-container="body"
            data-placement="left"
            data-toggle="popover"
            data-content="<p>Are you sure you want to remove this repository?</p>
            <a class='btn btn-default'>No</a> <a class='btn btn-primary yes'>Yes</a>"
            data-template="<div class='popover popover-repository-delete' role='tooltip'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div></div>'"
            data-html="true"
            role="button"
            title="Delete image"
            :disabled="state.isDeleting">
            <i class="fa fa-trash"></i>
            Delete repository
          </button>
        </div>
      </div>
    </div>

    <tags-panel :state="state" :tags="tags" :tags-path="tagsPath" :security-enabled="securityEnabled" :repository="repository"></tags-panel>
    <comments-wrapper :state="state" :comments-ref="commentsRef" :repository="repository"></comments-wrapper>
  </div>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

  import CommentsWrapper from '../components/comments/wrapper';
  import TagsPanel from '../components/tags/panel';
  import Star from '../components/star';

  import RepositoriesService from '../services/repositories';
  import TagsService from '../services/tags';

  import RepositoriesStore from '../store';

  const { set } = Vue;

  const POLLING_VALUE = 10000;

  export default {
    props: {
      repositoryRef: {
        type: Object,
      },
      commentsRef: {
        type: Array,
      },
      namespacePath: {
        type: String,
      },
      namespaceName: {
        type: String,
      },
      tagsPath: {
        type: String,
      },
      securityEnabled: {
        type: Boolean,
      },
      repositoryInformation: {
        type: String,
      },
    },

    components: {
      TagsPanel,
      CommentsWrapper,
      Star,
    },

    data() {
      const store = new RepositoriesStore();

      return {
        state: store.state,
        unableToFetchBefore: false,
        repository: { ...this.repositoryRef },
        tags: [],
      };
    },

    methods: {
      loadData() {
        if (this.state.isDeleting) {
          setTimeout(() => this.loadData(), POLLING_VALUE);
          return;
        }

        RepositoriesService.groupedTags(this.repository.id).then((response) => {
          set(this, 'tags', response.body);
          set(this.state, 'notLoaded', false);
          set(this, 'unableToFetchBefore', false);
        }, () => {
          if (this.state.isLoading) {
            set(this.state, 'notLoaded', true);
          }

          if (!this.state.isLoading && !this.unableToFetchBefore) {
            this.$alert.$show('Unable to fetch newer tags data');
            set(this, 'unableToFetchBefore', true);
          }
        }).finally(() => {
          setTimeout(() => this.loadData(), POLLING_VALUE);
          set(this.state, 'isLoading', false);
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
              this.$alert.$schedule('Repository removed with all its tags.');
              window.location.href = this.namespacePath;
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

        RepositoriesService.remove(this.repository.id).then(() => {
          this.$alert.$schedule('Repository removed with all its tags');
          window.location.href = this.namespacePath;
        }).catch(handleHttpResponseError)
          .finally(() => set(this.state, 'isDeleting', false));
      },

      toggleStar() {
        RepositoriesService.toggleStar(this.repository.id).then((response) => {
          set(this, 'repository', response.body);
        }).catch(handleHttpResponseError);
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
  };
</script>
