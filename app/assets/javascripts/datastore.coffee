#= require upload

Datastore =
  reload_files: ->
    window.location.reload()

  mkdir: (path) ->
    $.ajax Routes.datastore_mkdir(),
      method: 'PATCH'
      data:
        path: path
      success: ->
        Datastore.goto(path)
      error: ->

  cp: (src, dest) ->
    App.freeze_canvas()
    $.ajax Routes.datastore_cp(),
      method: 'PATCH'
      data:
        src: src
        dest: dest
      success: ->
        App.unfreeze_canvas()
        Datastore.goto(dest)
      error: ->
        App.unfreeze_canvas()
        notie.alert(3, 'Error occured when copying file')

  mv: (src, dest, goto=false) ->
    $.ajax Routes.datastore_mv(),
      method: 'PATCH'
      data:
        src: src
        dest: dest
      success: ->
        if goto
          Datastore.goto(dest)
        else
          Datastore.reload_files()
      error: ->
        notie.alert(3, 'Error occured when moving file')

  rename: (path, new_name, goto=false) ->
    Datastore.mv path, "#{path.split('/')[0..-2].join('/')}/#{new_name}", goto

  import_remote: (url, dest) ->
    $.get(Routes.datastore_import_remote(),
      {
        url: url,
        dest: dest
      }, ->
        Datastore.reload_files()
    )
  trash: (path) ->
    $.ajax Routes.datastore_trash(),
      method: 'DELETE'
      data:
        path: path
      success: ->
        Datastore.reload_files()
      error: ->
        notie.alert(3, 'Error occured when deleting file')

  goto: (path) ->
    window.location.href = Routes.datastore path: path

path_of_row = (el) ->
  $(el).parents('tr').data('path') || $(el).parents('.nav-toolbar').data('path')

within 'datastore', 'show, edit', ->
  $('.clear-job-dirs').click ->
    return true unless confirm('All empty job dirs will be deleted, are you sure?')

  $('.btn-import').click ->
    notie.input {
      type: 'text'
    }, 'Remote url:', 'OK', 'Cancel',
      (url) ->
        Datastore.import_remote(url, gon.path) if url

  $('.btn-mkdir').click ->
    notie.input {
      type: 'text'
    }, 'Folder name:', 'OK', 'Cancel',
      (dirname) ->
        Datastore.mkdir("#{gon.path}/#{dirname}") if dirname

  $('.btn-trash').click ->
    self = this
    notie.confirm 'Are you sure you want to delete this file?', 'Yes', 'Cancel', ->
      Datastore.trash path_of_row(self)

  $('.btn-go').click ->
    notie.input {
      type: 'text'
    }, 'Go to path:', 'OK', 'Cancel',
      (path) ->
        Datastore.goto path if path

  $('.btn-rename').click ->
    self = this
    notie.input {
      type: 'text'
    }, 'New name:', 'OK', 'Cancel',
      (name) ->
        if name
          src = path_of_row(self)
          goto = false
          unless src
            src = gon.path
            goto = true
          Datastore.rename src, name, goto if name

  $('.btn-paste').click ->

  $('.btn-copy').click ->
    src = path_of_row this
    App.dirSelector (dest) ->
      Datastore.cp src, dest

  $('.btn-move').click ->
    src = path_of_row this
    App.dirSelector (dest) ->
      Datastore.mv src, dest, true
