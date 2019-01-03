<template>
  <div class="repository-overview">
    <div class="col-sm-10 col-md-6">
      <h4 class="h5 title">Description</h4>
      <div v-html="repository.description_md" v-if="repository.description_md"></div>
      <em class="click-description" @click="enterEditMode" v-else>Click to set repository description</em>

      <hr v-if="state.descriptionFormVisible" />

      <form class="description-form" v-show="state.descriptionFormVisible" @submit.prevent="submit">
        <div class="form-group">
          <textarea id="repository_description" name="repository[description]" class="form-control fixed-size" placeholder="A short description of your repository" v-model="repositoryCopy.description" ref="description"></textarea>
        </div>
        <div class="form-group">
          <button type="submit" class="btn btn-primary">Save</button>
        </div>
      </form>
    </div>

    <div class="col-sm-10 col-md-6 more-info">
      <h4 class="h5 title">More information</h4>
      <div v-html="info"></div>
    </div>
  </div>
</template>

<script>
  import Vue from 'vue';

  import RepositoriesService from '../services/repositories';

  const { set, nextTick } = Vue;

  export default {
    props: {
      state: Object,
      repository: Object,
      info: String,
    },

    data() {
      return {
        repositoryCopy: {},
      };
    },

    methods: {
      handleFormState(value) {
        if (!value) {
          return;
        }

        this.enterEditMode();
      },

      enterEditMode() {
        set(this.state, 'descriptionFormVisible', true);
        set(this, 'repositoryCopy', { ...this.repository });

        nextTick().then(() => {
          this.$refs.description.focus();
        });
      },

      leaveEditMode() {
        set(this.state, 'descriptionFormVisible', false);
      },

      submit() {
        RepositoriesService.update(this.repositoryCopy).then((response) => {
          const repository = response.data;

          this.$alert.$show("Repository's description was updated successfully");
          this.$bus.$emit('repositoryUpdated', repository);
          this.leaveEditMode();
        });
      },
    },

    watch: {
      'state.descriptionFormVisible': 'handleFormState',
    },
  };
</script>
