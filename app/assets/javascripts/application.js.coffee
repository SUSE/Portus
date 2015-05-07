//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require twitter/bootstrap
//= require_tree .

$(document).on "page:change", ->
  $('#notice .close').on 'click', (event) =>
    $('#notice').hide()
  $('#alert .close').on 'click', (event) =>
    $('#alert').hide()

