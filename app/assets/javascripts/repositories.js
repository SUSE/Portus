jQuery(function ($) {
  const WRITE_COMMENT_BTN = '#write_comment_repository_btn';
  const $body = $('body');

  // Shows and hides the comment form
  $body.off('click', WRITE_COMMENT_BTN);
  $body.on('click', WRITE_COMMENT_BTN, (_e) => {
    $('#write_comment_form').toggle(400, 'swing', function () {
      if ($('#write_comment_form').is(':visible')) {
        $('#comment_body').focus();
        layout_resizer();
      }
    });
  });
});
