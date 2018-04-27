<template>
  <div class="container-full">
    <div v-if="comments.length">
      <comments-list-item :comment="comment" v-for="comment in comments" :key="comment.id">
      </comments-list-item>
    </div>
    <p v-else>
      Nobody has left a comment yet
    </p>
  </div>
</template>

<script>
  import CommentsListItem from './list-item';

  export default {
    props: ['comments'],

    components: {
      CommentsListItem,
    },
  };
</script>
