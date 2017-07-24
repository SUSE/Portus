import BaseComponent from '~/base/component';

import CommentForm from '../components/comment-form';

class CommentsPanel extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find('.add-comment');
    this.$commentForm = this.$el.find('.comment-form');
  }

  events() {
    this.$toggle.on('click', () => this.toggle());
  }

  mount() {
    this.form = new CommentForm(this.$commentForm);
  }

  toggle() {
    this.form.toggle();
  }
}

export default CommentsPanel;
