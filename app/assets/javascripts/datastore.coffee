Datastore =
  reload_files: ->
    window.location.reload()

  mkdir: (dirname) ->
    dirpath = "#{gon.pwd}/#{dirname}"
    $.ajax Routes.datastore_mkdir(),
      method: 'patch'
      data:
        dirpath: dirpath
      success: ->
        console.debug 'a'
        Datastore.reload_files()
      error: ->
        console.debug 'a'

$ ->
  $('.btn-mkdir').click ->
    dirname = prompt('Directory name:')
    Datastore.mkdir(dirname) if dirname
