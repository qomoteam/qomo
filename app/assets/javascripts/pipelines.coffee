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


within 'pipelines', 'index', ->
  $('.shared-toggle').change ->
    toggle = this
    toggle.busy = true
    isChecked = toggle.checked
    pid = $(this).parents('tr').data 'pid'
    url = if isChecked then Routes.share_pipeline(pid) else Routes.unshare_pipeline(pid)
    $.ajax
      url: url
      method: 'PATCH'
      error: ->
        toggle.checked = !isChecked
        toggle.busy = false
      success: ->
        toggle.busy = false