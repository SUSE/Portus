$(document).ready ->
  $('#starred a').on 'click', (event) ->
    e.preventDefault()
    $(this).tab('show')

  $('#all a').on 'click', (event) ->
    e.preventDefault()
    $(this).tab('show')

  $('#personal a').on 'click', (event) ->
    e.preventDefault()
    $(this).tab('show')
