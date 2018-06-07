<template>
  <div>
    <comments-form :state="state" form-state="commentFormVisible" :repository="repository"></comments-form>
    <comments-panel :comments="comments" :state="state"></comments-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import CommentsForm from './form';
  import CommentsPanel from './panel';

  const { set } = Vue;

  export default {
    props: ['state', 'commentsRef', 'repository'],

    data() {
      return {
        comments: [...this.commentsRef],
      };
    },

    components: {
      CommentsForm,
      CommentsPanel,
    },

    methods: {
      onCommentAdded(comment) {
        const newComments = [
          comment,
          ...this.comments,
        ];

        set(this, 'comments', newComments);
      },

      onCommentDestroyed(comment) {
        const currentComments = this.comments;
        const index = currentComments.findIndex(c => c.id === comment.id);

        const members = [
          ...currentComments.slice(0, index),
          ...currentComments.slice(index + 1),
        ];

        set(this, 'comments', members);
      },
    },

    created() {
      this.$bus.$on('commentAdded', comment => this.onCommentAdded(comment));
      this.$bus.$on('commentDestroyed', comment => this.onCommentDestroyed(comment));
    },
  };
</script>
