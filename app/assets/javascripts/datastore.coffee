Datastore =
  reload_files: ->
    window.location.reload()

  mkdir: (dirname) ->
    dirpath = "#{gon.pwd}/#{dirname}"
    $.ajax Routes.datastore_mkdir(),
      method: 'PATCH'
      data:
        dirpath: dirpath
      success: ->
        Datastore.reload_files()
      error: ->
        console.debug 'a'

  trash: (path) ->
    $.ajax Routes.datastore_trash(),
      method: 'DELETE'
      data:
        path: path
      success: ->
        Datastore.reload_files()
      error: ->
        console.debug 'a'

$ ->
  $('.btn-mkdir').click ->
    dirname = prompt('Directory name:')
    Datastore.mkdir(dirname) if dirname

  $('.btn-trash').click ->
    Datastore.trash $(this).parents('tr').data('path')
