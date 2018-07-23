<template>
  <div class="comment-row" :id="commentId">
    <div class="comment-thumbnail">
      <div class="user-image">
        <img :src="comment.author.avatar_url" v-if="comment.author.avatar_url" />
        <i class="fa fa-user user-picture" v-else></i>
      </div>
    </div>
    <div class="comment-content">
      <div class="row">
        <p class="col-xs-8">
          <strong>{{ comment.author.username }}</strong>
          <span class="text-muted space-xs-sides">{{ createdAt }}</span>
        </p>
        <div class="col-xs-4 text-right" v-if="comment.destroyable">
          <button class="btn btn-link btn-xs delete-comment-btn"
            data-placement="left"
            data-toggle="popover"
            data-title="Please confirm"
            data-content="<p>Are you sure you want to remove this\
            comment?</p><a class='btn btn-default'>No</a> <a class='btn \
            btn-primary yes'>Yes</a>"
            data-template="<div class='popover popover-comment-delete' role='tooltip'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div></div>'"
            data-html="true"
            role="button">
            <i class="fa fa-trash"></i>
            Delete comment
          </button>
        </div>
      </div>
      <div v-html="comment.body_md"></div>
    </div>
  </div>
</template>

<script>
  import dayjs from 'dayjs';

  import CommentsService from '../../services/comments';

  export default {
    props: ['comment'],

    computed: {
      commentId() {
        return `comment_${this.comment.id}`;
      },

      createdAt() {
        return dayjs(this.comment.created_at).fromNow();
      },
    },

    methods: {
      delete() {
        CommentsService.remove(this.comment.repository_id, this.comment.id).then(() => {
          this.$bus.$emit('commentDestroyed', this.comment);
          this.$alert.$show('Comment was deleted successfully');
        });
      },
    },

    mounted() {
      const DELETE_BTN = '.delete-comment-btn';
      const POPOVER_DELETE = '.popover-comment-delete';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', DELETE_BTN, () => {
        const $yes = $(POPOVER_DELETE).find('.yes');
        $yes.click(this.delete.bind(this));
      });
    },
  };
</script>
