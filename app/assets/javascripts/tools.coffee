within 'tools', 'new, edit', ->
  $(document).on 'change', 'select[name="tool[params][][type]"]', ->
    console.debug this.value
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
