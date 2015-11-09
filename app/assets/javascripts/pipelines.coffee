within 'pipelines', 'show', ->
  $('input.input.value').each ->
    App.bindFileSelector(this)