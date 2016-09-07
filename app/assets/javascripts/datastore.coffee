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
        Datastore.reload_files()
      error: ->
        console.debug 'a'

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
        console.debug 'a'

  rename: (path, new_name, goto=false) ->
    Datastore.mv path, "#{path.split('/')[0..-2].join('/')}/#{new_name}", goto

  trash: (path) ->
    $.ajax Routes.datastore_trash(),
      method: 'DELETE'
      data:
        path: path
      success: ->
        Datastore.reload_files()
      error: ->
        console.debug 'a'

  goto: (path) ->
    window.location.href = Routes.datastore path: path

path_of_row = (el) ->
  $(el).parents('tr').data('path')

within 'datastore', 'show', ->
  $('.shared-toggle').change ->
    toggle = this
    toggle.busy = true
    isChecked = toggle.checked
    path = $(this).parents('tr').data 'path'
    url = if isChecked then Routes.datastore_share(path: path) else Routes.datastore_unshare(path: path)
    $.ajax
      url: url
      method: 'PATCH'
      error: ->
        toggle.checked = !isChecked
        toggle.busy = false
      success: ->
        toggle.busy = false

  $('.clear-job-dirs').click ->
    return true unless confirm('All empty job dirs will be deleted, are you sure?')


  $('.btn-mkdir').click ->
    dirname = prompt('Directory name:')
    Datastore.mkdir("#{gon.path}/#{dirname}") if dirname

  $('.btn-trash').click ->
    Datastore.trash path_of_row(this)

  $('.btn-go').click ->
    path = prompt('Go to:')
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
