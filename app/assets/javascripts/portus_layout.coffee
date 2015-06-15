# Jquery to give the final touches to Portus layout

openSearchForm = ->
  $('.header-open-search').on 'click', ->
    $(this).fadeOut '300', ->
      $(this).remove()
      return
    $('.header-search-form .btn-default').show 'slow'
    $('.search-field').show('slow').focus()
    return

  $('#search').keyup ->
    if $('#search').val() == ''
      $('.header-search-form button').attr 'disabled', 'disabled'
    else
      $('.header-search-form button').removeAttr 'disabled'
    return
  return

$(document).on 'ready', ->
  openSearchForm()
  return
