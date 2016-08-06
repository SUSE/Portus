$ ->
  $("#filter_input").on 'keyup', ->
    $.get $('#filter_form').attr('action'), $('#filter_form').serialize(), null, 'script'
    return