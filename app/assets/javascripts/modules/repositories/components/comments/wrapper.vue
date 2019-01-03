<template>
  <div class="comments-wrapper">
    <comments-form :state="state" form-state="commentFormVisible" :repository="repository"></comments-form>

    <hr v-if="state.commentFormVisible"/>

    <comments-list :comments="comments"></comments-list>
  </div>
</template>

<script>
  import Vue from 'vue';

  import CommentsForm from './form';
  import CommentsList from './list';

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
      CommentsList,
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
