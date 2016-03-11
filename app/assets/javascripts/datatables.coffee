$(document).on "page:change", ->
  $.extend $.fn.dataTable.defaults,
    searching: false,
    ordering: true,
    'paging': true,
    bInfo: false,           # Disable Information in the footer
    aaSorting: [],          # Disable initial sort
    'bLengthChange': false,
    'pageLength': 10

  repositories_table = {
    'id': 'repositories-table',
    'columns':  [ { name: 'repository' }, { name: 'tags' } ],
    'paging': true
  }

  tags_table = {
    'id': 'tags-table',
    'columns': [ { name: 'tag', 'orderable': false },
      { name: 'author', 'orderable': false },
      { name: 'pushed_at' } ],
    'paging': false
  }

  teams_table = {
    'id': 'teams-table',
    'columns': [ { name: 'icon', 'orderable': false },
      { name: 'team' },
      { name: 'owner' },
      { name: 'number_of_members' },
      { name: 'number_of_namespaces' } ],
    'paging': true
  }

  members_table = {
    'id': 'members-table',
    'columns': [ { name: 'icon', 'orderable': false},
      { name: 'user' },
      { name: 'role' },
      { name: 'edit', 'orderable': false },
      { name: 'remove', 'orderable': false } ],
    'paging': true
  }

  snamespaces_table = {
    'id': 'snamespaces-table',
    'columns': [ { name: 'namespace' },
      { name: 'repositories' },
      { name: 'created_at' },
      { name: 'public', 'orderable': false } ],
    'paging': false
  }

  namespaces_table = {
    'id': 'namespaces-table',
    'columns': snamespaces_table['columns']
    'paging': true
  }

  registries_table = {
    'id': 'registries-table',
    'columns': [ { name: 'name', 'orderable': false },
      { name: 'hostname' },
      { name: 'ssl', 'orderable': false },
      { name: 'edit', 'orderable': false } ],
    'paging': false
  }

  admin_users_table = {
    'id': 'admin-users-table',
    'columns': [ { name: 'name' },
      { name: 'email' },
      { name: 'admin', 'orderable': false },
      { name: 'namespaces' },
      { name: 'teams' },
      { name: 'enabled', 'orderable': false } ],
    'paging': true
  }

  admin_teams_table = {
    'id': 'admin-teams-table',
    'columns': [ { name: 'icon', 'orderable': false },
      { name: 'team' },
      { name: 'role' },
      { name: 'hidden', 'orderable': false },
      { name: 'number_of_members' },
      { name: 'number_of_namespaces' } ],
    'paging': true
  }

  tables = [
    repositories_table,
    tags_table,
    teams_table,
    members_table,
    snamespaces_table,
    namespaces_table,
    registries_table,
    admin_users_table,
    admin_teams_table
  ]


  createDataTables = (table) ->
    id = table['id']
    columns = table['columns']
    if table['paging']
      dom = 't<"datatables_footer_' + id + '"<"pull-left"p><"clearfix">>'
    else
      dom = 't<"clearfix">'
    if !$.fn.DataTable.isDataTable('#' + id)
      $('#' + id).DataTable(
        columns: columns,
        'dom': dom,
        'paging': table['paging'],
        'fnDrawCallback': (oSettings) ->
          $('.paging_' + id).append($('.datatables_footer_' + id +  ' > div'))
          if oSettings._iDisplayLength > oSettings.fnRecordsDisplay()
            $('.paging_' + id).hide()
      )

  for table in tables
    createDataTables(table)
