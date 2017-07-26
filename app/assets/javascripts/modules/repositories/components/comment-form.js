import BaseComponent from '~/base/component';

const COMMENT_BODY = '#comment_body';

class CommentForm extends BaseComponent {
  elements() {
    this.$commentBody = this.$el.find(COMMENT_BODY);
  }

  toggle() {
    this.$el.toggle(400, 'swing', () => {
      const visible = this.$el.is(':visible');

      if (visible) {
        this.$commentBody.focus();
      }

      layout_resizer();
    });
  }
}

export default CommentForm;
