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
    $(this).parents('.param-def').find('td.defautl-value-td').html $("#tpl_param_#{this.value}").text()

  dragula([document.getElementById('param-defs')])

  $(document).on 'click', '.param-def .edit-options', ->
    $options = $(this).parents('td').find('.options')
    if $options.is(':visible')
      $options.hide()
    else
      console.debug $options
      offset = $(this).position()
      width = $(this).outerWidth()
      height = $(this).outerHeight()
      popupWidth = $options.width()

      $options.css
        top    : offset.top + height + 1
        left   : offset.left + (width / 2) - (popupWidth / 2) + 1
        bottom : 'auto'
        right  : 'auto'
      $options.show()

  $(document).on 'click', '.remove-param', ->
    $(this).parents('.param-def').fadeOut ->
      $(this).remove()


  $(document).on 'click', '.param-def .options button.ok', ->
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

  $('.add-param').click ->
    $target = $('#param-defs')
    $target.append $('#tpl_table_param_def').text()
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
        minimum: 2
        maximum: 30
    'tool[command]':
      presence: true

  App.validate($('#edit-tool-form'), constrains)
