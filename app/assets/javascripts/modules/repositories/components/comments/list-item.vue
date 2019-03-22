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
          <popover title="Please confirm" placement="left" v-model="confirm">
            <button class="btn btn-default delete-app-token-btn" role="button">
              <i class="fa fa-trash"></i>
              Delete comment
            </button>
            <template slot="popover">
              <div class='popover-content'>
                <p>Are you sure you want to remove this comment?</p>
                <a class='btn btn-default' @click="confirm = false">No</a>
                <a class='btn btn-primary yes' @click="destroy">Yes</a>
              </div>
            </template>
          </popover>
        </div>
      </div>
      <div v-html="comment.body_md"></div>
    </div>
  </div>
</template>

<script>
  import dayjs from 'dayjs';

  import { Popover } from 'uiv';
  import CommentsService from '../../services/comments';

  export default {
    data() {
      return {
        confirm: false,
      };
    },

    props: ['comment'],

    components: {
      Popover,
    },

    computed: {
      commentId() {
        return `comment_${this.comment.id}`;
      },

      createdAt() {
        return dayjs(this.comment.created_at).fromNow();
      },
    },

    methods: {
      destroy() {
        CommentsService.remove(this.comment.repository_id, this.comment.id).then(() => {
          this.$bus.$emit('commentDestroyed', this.comment);
          this.$alert.$show('Comment was deleted successfully');
        });
      },
    },
  };
</script>
