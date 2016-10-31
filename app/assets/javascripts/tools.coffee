within 'tools', 'show', ->
  $('input.input.value').each ->
    App.bindFileSelector(this)

within 'tools', 'new, edit', ->
  $('input[type=checkbox].mkexe-asset').click ->
    $.post Routes.asset_mkexe_tool(this.dataset.tid),
      path: this.dataset.path

  $(document).on 'change', 'select[name="tool[params][][type]"]', ->
    $(this).parents('.param-def').find('td.defautl-value-td').html $("#tpl_param_#{this.value}").text()

  $(document).on 'click', '.param-def .edit-options', ->
    $options = $(this).parents('td').find('.options')
    if $options.is(':visible')
      $options.hide()
    else
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


  $('aui-toggle input[name=runnable]').change ->
    if this.checked
      $('.runtime-settings').fadeIn()
    else
      $('.runtime-settings').fadeOut()

  $('input[name="tool[tag_list]"]').auiSelect2
    tags: true
    tokenSeparators: [',']
    minimumInputLength: 1
    multiple: true
    initSelection: (e, callback) ->
      data = []
      $(e.val().split(',')).each ->
        data.push
          id: this
          text: this
      callback(data)
    createSearchChoice: (term, data) ->
      if ($(data).filter(-> this.text.localeCompare(term) == 0).length == 0)
        {
          id: term
          text: term
        }
    ajax:
      url: Routes.tags_tools()
      dataType: 'json'
      delay: 250
      cache: true
      data: (term) ->
        q: term
      results: (data) ->
        results: data

  $(document).on 'click', '.publication_search', (e) ->
    e.preventDefault()
    $table = $(this).closest('table.publication')
    pmid = $table.find('input[name="tool[publications][][pmid]"]').val()
    return unless pmid
    $i = $(this).find('i')
    $i.attr('class', 'fa fa-spinner fa-spin fa-fw')
    $.get Routes.publication_search(), {pmid: pmid}, (p) ->
      $i.attr('class', 'fa fa-search')
      return unless p.pmid
      $table.find('input[name="tool[publications][][title]"]').val(p.title)
      $table.find('input[name="tool[publications][][authors]"]').val(p.authors.join(', '))
      $table.find('input[name="tool[publications][][journal]"]').val(p.journal)
      $table.find('input[name="tool[publications][][date]"]').val(p.date)
      $table.find('input[name="tool[publications][][issue]"]').val(p.issue)
      $table.find('input[name="tool[publications][][volume]"]').val(p.volume)
      $table.find('input[name="tool[publications][][doi]"]').val(p.doi)
      $table.find('input[name="tool[publications][][citation]"]').val(p.citation)
