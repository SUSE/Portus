# Jquery to give the final touches to Portus layout

window.openSearchForm = ->
  $('#search').keyup ->
    if $('#search').val() == ''
      $('.header-search-form button').attr 'disabled', 'disabled'
    else
      $('.header-search-form button').removeAttr 'disabled'
    return

$(document).on 'ready', ->
  openSearchForm()
  return
