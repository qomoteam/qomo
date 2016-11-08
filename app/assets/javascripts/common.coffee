#= require js-routes
#= require jquery-migrate
#= require jquery-ui
#= require jquery-ujs
#= require artDialog
#= require jquery-form
#= require underscore
#= require patch
#= require notie
#= require aui
#= require spin
#= require rails.validations
#= require pace
#= require dragula
#= require readmore
#= require jquery.raty
#= require ratyrate
#= require social-share-button
#= require social-share-button/wechat

class GUID
  s4: ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)

  create: () ->
    "#{@s4()}#{@s4()}-#{@s4()}-#{@s4()}-#{@s4()}-#{@s4()}#{@s4()}#{@s4()}"

#TODO externalize
tpl_fileselector = ""

spinner = new Spinner
  length: 50
  width: 10
  lines: 9
  radius: 60

window.App =
  scopes: {}

  freeze_canvas: ->
    $('#freeze_layer').show()
    spinner.spin()
    document.getElementById('freeze_layer').appendChild(spinner.el)

  unfreeze_canvas: ->
    $('#freeze_layer').hide()
    spinner.stop()

  goto: (url) ->
    Turbolinks.visit(url)

  open: (url) ->
    window.open(url)

  getSelectedRowIds: ($table)->
    row_ids = []
    $table.find('tr td:first-of-type input[type=checkbox]:checked').each ->
      row_ids.push $(this).parents('tr').data 'row-id'
    return row_ids

  setSelectValues: (select, values)->
    values = [] unless values
    $(select).val(values).trigger('change')
#    $(select).find('option').each ->
#      console.debug this.value in values
#      $(this).prop('selected', this.value in values)

  guid: ->
    new GUID().create()

  token: ->
    $('meta[name=csrf-token]').attr('content')

  dirSelector: (onOk) ->
    $.get Routes.datastore_dirselector(), (dirselector) ->
      currentTree = null
      dia = dialog
        title: 'Select Directory'
        content: dirselector
        width: 700
        okValue: 'OK'
        ok: ->
          selectedPath = currentTree.jstree('get_selected')[0]
          onOk(selectedPath)
          return true
        cancel: ->
        cancelValue: 'Cancel'

      dia.showModal()
      tree = $(dia.node).find('.tree')
      currentTree = tree.jstree
        core:
          animation: 0
          themes:
            stripes: true
          data:
            url: tree.data('url')
            data: (node) ->
              'dir' : if node.id == '#' then '' else node.id


  bindFileSelector: (e)->
    $e = $(e)
    window.filetree = null
    $.get Routes.datastore_fileselector(selected: $e.val()), (fileselector) ->
      $e.click ->
        did = App.guid()
        dia = dialog
          id: did
          title: 'Select File'
          content: fileselector
          width: 700
          okValue: 'OK'
          ok: ->
            value = $(document.getElementById("content:#{did}")).find('.path').val()
            $e.val value
            $e.trigger 'change'
            return true
          cancelValue: 'Cancel'
          cancel: ->
        $(document.getElementById("content:#{did}")).find('.path').val $e.val()
        AJS.tabs.setup()
        dia.showModal()

        $(document.getElementById("content:#{did}")).find('.tree').each ->
          url = this.dataset.url
          $(this).jstree(
              core:
                animation: 0
                themes:
                  stripes: true
                data:
                  url: url
                  data: (node) ->
                    dir : if node.id == '#' then '' else node.id
                    selected: $e.val()
            ).on 'changed.jstree', (je, e) ->
              # Use comma to seqerate multiple inputs
              $(document.getElementById("content:#{did}")).find('.path').val e.selected.join(',')

$ ->
  AJS.$('select.select2').auiSelect2()

  $(document).on 'click', '.remove-tr', (e) ->
    e.preventDefault()
    href = this.href
    params = {}
    $this = $(this)
    delete_tr = ->
      $this.closest('tr').remove()
    for k of this.dataset
      if k.indexOf('param') == 0
        remote = true
        params[k.substring('param'.length)] = this.dataset[k]
    $.ajax
      url: href
      method: 'delete'
      data: params
      success: delete_tr


  $(document).on 'click', '.remove-table', ->
    $(this).closest('table').fadeOut ->
      $(this).remove()

  if gon.notice
    notie.alert 4, gon.notice, 100

  $('.logout').click ->
    localStorage.clear()
    true

  tinymce.init
    selector: '.tinymce'
    menubar: false
    statusbar: false
    content_style: 'body {font-size: 12px !important}'
    plugins: [
      'advlist autolink lists link image charmap print preview hr anchor pagebreak',
      'searchreplace wordcount visualblocks visualchars code fullscreen',
      'insertdatetime media nonbreaking save table contextmenu directionality',
      'emoticons template paste textcolor colorpicker textpattern imagetools fullpage'
    ]
    toolbar: 'styleselect | bold italic underline removeformat | forecolor backcolor | bullist numlist outdent indent | link unlink | image table ｜fullscreen code'
    image_advtab: true
    toolbar_items_size: 'small'


  $.expr[':'].external = (obj) ->
    !obj.href.match(/^mailto:/) && (obj.hostname != location.hostname) && !obj.href.match(/^javascript:/) && !obj.href.match(/^$/)

  $('#content a:external:not(.no-external-link)').attr('target', '_blank').addClass('external-link')

  $('.readmore').readmore
    blockCSS: 'overflow-x: scroll !important;'

  $('aui-toggle input[type=checkbox]').change ->
    $(this).parent().prev().val(this.checked)

  $('.add-el-from-template').click (e) ->
    e.preventDefault()
    $tpl = $(document.getElementById(this.dataset.template))
    $target = $(document.getElementById(this.dataset.target))
    $target.find('.empty-placeholder').hide()
    $target.append $tpl.text()

  $('.draggable-container').each ->
    dragula [this]

  $('*[data-warning]').click ->
    content = this.dataset.warning
    notie.alert(2, content)

  $('a.rucaptcha-image-box').click (e) ->
    console.debug 1
    btn = $(e.currentTarget)
    img = btn.find('img:first')
    currentSrc = img.attr('src')
    img.attr('src', currentSrc.split('?')[0] + '?' + (new Date()).getTime())
    e.preventDefault()
