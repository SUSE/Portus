$ ->
  $("#search_input").on 'keyup', ->
    $.get $('#search_form').attr('action'), $('#search_form').serialize(), null, 'script'
    return