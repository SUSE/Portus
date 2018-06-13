<template>
  <form id="new-comment-form" role="form" class="form-horizontal collapse"
    ref="form" @submit.prevent="onSubmit">
    <div class="form-group has-feedback" :class="{ 'has-error': $v.comment.body.$error }">
      <label for="comment_body" class="control-label col-md-2">Comment</label>
      <div class="col-md-7">
        <textarea placeholder="Please write a comment." name="comment[body]" id="comment_body" class="form-control fixed-size" ref="firstField" @input="$v.comment.body.$touch()" v-model.trim="comment.body"></textarea>
        <span class="help-block">
          <span v-if="!$v.comment.body.required">
            Comment can't be blank
          </span>
        </span>
      </div>
    </div>
    <div class="form-group">
      <div class="col-md-offset-2 col-md-7">
        <input type="submit" name="commit" value="Add" class="btn btn-primary" :disabled="$v.$invalid">
      </div>
    </div>
  </form>
</template>

<script>
  import { required } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import FormMixin from '~/shared/mixins/form';

  import CommentsService from '../../services/comments';

  export default {
    props: ['repository'],

    mixins: [FormMixin],

    data() {
      return {
        comment: {
          body: null,
        },
      };
    },

    methods: {
      onSubmit() {
        CommentsService.save(this.repository.id, this.comment).then((response) => {
          const comment = response.data;

          this.toggleForm();
          this.$bus.$emit('commentAdded', comment);
          this.$alert.$show('Comment was posted successfully');
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      comment: {
        body: {
          required,
        },
      },
    },
  };
</script>
