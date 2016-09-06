within 'tools', 'new, edit', ->

  $('input[type=checkbox].mkexe-asset').click ->
    $.post Routes.asset_mkexe_tool(this.dataset.tid),
      path: this.dataset.path

  $('a.delete-asset').click ->
    $this = $(this)
    $.post this.href,
      success: ->
        $this.parents('tr').remove()
    return false

  $(document).on 'change', 'select[name="tool[params][][type]"]', ->
    $(this).parents('td').next().html $("#tpl_param_#{this.value}").text()

  $(document).on 'click', '.params-def .edit-options', ->
    $options = $(this).parents('tr').find('.options')
    offset = $(this).position()
    width = $(this).outerWidth()
    height = $(this).outerHeight()
    popupWidth   = $options.width()

    $options.css
      top    : offset.top + height + 1
      left   : offset.left + (width / 2) - (popupWidth / 2) + 1
      bottom : 'auto'
      right  : 'auto'

    $options.show()


  $(document).on 'click', '.params-def .options button.ok', ->
    $(this).parents('.options').hide()
    return false

  $(document).on 'click', '.add-tr', ->
    sel_target = $(this).data 'target'
    $target = {}
    if sel_target
      $target = $(sel_target)
    else
      $target = $(this).closest('table')

    $tr_empty = $target.find('tbody tr.empty')
    if $tr_empty.length > 0
      $tr_empty.remove()

    sel_tpl_tr = $(this).data 'tpl'

    $target.append $(sel_tpl_tr).text()
    return false

  $(document).on 'click', '.remove-tr', ->
    remote = false
    params = {}
    $this = $(this)
    delete_tr = ->
      $this.closest('tr').remove()
    for k of this.dataset
      if k.indexOf('param') == 0
        remote = true
        params[k.substring('param'.length)] = this.dataset[k]

    if remote
      $.ajax
        url: this.href
        method: 'delete'
        data: params
        success: run
    else
      delete_tr()

    return false


  constrains =
    'tool[name]':
      presence: true
      length:
        minimum: 5
        maximum: 12
    'tool[command]':
      presence: true

  App.validate($('.edit-tool-form'), constrains)
