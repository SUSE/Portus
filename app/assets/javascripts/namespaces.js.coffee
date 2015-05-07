$(document).on "page:change", ->
  for btn_edit_namespace in $(".btn-edit-namespace")
    $(btn_edit_namespace).on 'click', (event) =>
      $('#namespace_' + event.currentTarget.value + ' td .visibility').toggle()
      $('#change_namespace_' + event.currentTarget.value).toggle()
