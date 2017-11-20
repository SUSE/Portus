<template>
  <div>
    <button type="button" class="btn btn-danger tag-delete-btn" @click="deleteTags()" v-if="state.selectedTags.length > 0">
      <i class="fa fa-trash"></i>
      Delete {{ tagNormalized }}
    </button>
  </div>
</template>

<script>
  export default {
    props: ['state'],

    computed: {
      tagNormalized() {
        const moreThanOne = this.state.selectedTags.length > 1;
        const hasMultiple = this.state.selectedTags.length &&
          this.state.selectedTags[0].multiple;

        if (moreThanOne || hasMultiple) {
          return 'tags';
        }
        return 'tag';
      },
    },

    methods: {
      deleteTags() {
        this.$bus.$emit('deleteTags');
      },
    },
  };
</script>
