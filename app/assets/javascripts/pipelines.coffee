within 'pipelines', 'show', ->
  $('input.input.value').each ->
    App.bindFileSelector(this)

  $('form.pipeline-runner').submit (e) ->
    $form = $(this)
    pvalues = []
    $form.find('.pipeline-param').each ->
      value = $(this).find('input.value').val() || $(this).find('select.value').val()
      pvalues.push {name: $(this).data('name'), box_id: $(this).data('bid'), value: value}
    $form.find('input[name=pipelinevalues]').val JSON.stringify(pvalues)
