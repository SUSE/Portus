$(document).on "page:change", ->

  # Shows and hides the comment form
  $('#write_comment_repository_btn').unbind('click').on 'click', (event) ->
      $('#write_comment_form').toggle 400, "swing", ->
        if $('#write_comment_form').is(':visible')
          $('#comment_body').focus()
          layout_resizer()
