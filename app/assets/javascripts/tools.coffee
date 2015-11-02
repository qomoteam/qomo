within 'tools', 'new', ->
  $(document).on 'change', 'select[name="tool[params][][type]"]', ->
    $(this).parents('td').next().html $("#tpl_param_#{this.value}").text()
