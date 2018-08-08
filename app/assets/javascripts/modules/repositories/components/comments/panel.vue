<template>
  <div class="panel panel-default">
    <div class="panel-heading">
      <div class="row">
        <div class="col-sm-6">
          <h5>
            <span class="number_of_comments badge">{{ comments.length }}</span>
            <span class="comment_string"> Comments</span>
          </h5>
        </div>
        <div class="col-sm-6 text-right">
          <toggle-link text="Write comment" :state="state" state-key="commentFormVisible" class="toggle-link-new-comment" false-icon="fa-comment" true-icon="fa-close"></toggle-link>
        </div>
      </div>
    </div>
    <div class="panel-body panel-no-side-padding">
      <comments-list :comments="comments"></comments-list>
    </div>
  </div>
</template>

<script>
  import CommentsList from './list';

  export default {
    props: ['comments', 'state'],

    components: {
      CommentsList,
    },
  };
</script>
