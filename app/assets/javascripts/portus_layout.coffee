# Jquery to give the final touches to Portus layout

window.openSearchForm = ->
  $('.header-open-search').on 'click', ->
    $(this).fadeOut '300'
    $('#search').val('')
    $('.header-search-form .btn-default').show 'slow'
    $('.search-field').show('slow').focus()
    return

  $('#search').keyup ->
    if $('#search').val() == ''
      $('.header-search-form button').attr 'disabled', 'disabled'
    else
      $('.header-search-form button').removeAttr 'disabled'
    return

  $('#search').focusout ->
    $('.header-search-form .btn-default').hide()
    $('.header-open-search').show()
    $('.search-field').hide()
    $('#search').val('')
    return
  return

$(document).on 'ready', ->
  openSearchForm()
  return
