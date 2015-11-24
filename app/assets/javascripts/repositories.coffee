$(document).on "page:change", ->
  $.extend $.fn.dataTable.defaults,
    searching: false,
    ordering: true,
    bPaginate: false,   # Disable paginate
    bInfo: false,       # Disable Information in the footer
    aaSorting: []       # Disable initial sort

  $('.customized-datatable').DataTable(columns: [
    { name: 'tag', "orderable": false },
    { name: 'author', "orderable": false },
    { name: 'pushed_at' }
  ])
