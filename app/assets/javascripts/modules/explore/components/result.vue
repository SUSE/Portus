<template>
  <div>
    <div v-if="repositories.length">
      <h2>{{ repositories.length }} {{ repositoriesPluralized }} {{ wasWere }} found</h2>
      <ul class="result-list">
        <result-item :repository="repository" v-for="repository in repositories" :key="repository.full_name"></result-item>
      </ul>
    </div>

    <h2 v-if="emptySearch">Your search did not match any repositories.</h2>
  </div>
</template>

<script>
  import ResultItem from './result-item';

  export default {
    props: {
      repositories: Array,
    },

    components: {
      ResultItem,
    },

    computed: {
      repositoriesPluralized() {
        if (this.repositories.length > 1) {
          return 'repositories';
        }

        return 'repository';
      },

      wasWere() {
        if (this.repositories.length > 1) {
          return 'were';
        }

        return 'was';
      },

      emptySearch() {
        return !this.repositories.length && window.location.search.indexOf('explore') !== -1;
      },
    },
  };
</script>
