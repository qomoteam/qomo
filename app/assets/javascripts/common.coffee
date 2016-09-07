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
#= require quill
#= require validate
#= require pace

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

  validate: ($form, constrains) ->
    $form.submit (e) ->
      errors = validate this, constrains
      $form = $(this)
      if errors
        for field, msgs of errors
          errorMsg = ''
          if msgs.length > 1
            errorMsg = '"' + ("#{msg}" for msg in msgs).join(',') + '"'
          else
            errorMsg = msgs[0]
          $form.find("*[name='#{field}']")
          .attr('data-aui-notification-field', true)
          .attr('data-aui-notification-error', errorMsg)
        return false
      else
        return true

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

  bindFileSelector: (e)->
    $e = $(e)
    window.filetree = null
    $.get Routes.fileselector_workspace(), (fileselector) ->
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
                    'dir' : if node.id == '#' then '' else node.id
            ).on 'changed.jstree', (je, e) ->
              # Use comma to seqerate multiple inputs
              $(document.getElementById("content:#{did}")).find('.path').val e.selected.join(',')

$ ->
  AJS.$('select.select2').auiSelect2()

  if gon.notice
    notie.alert 4, gon.notice, 100

  $('.logout').click ->
    localStorage.clear()
    true

  $('textarea.quill').each ->
    $qe = $("<div class=\"quill\" data-textarea=''>#{$(this).val()}</div>")
    $qe.insertBefore($(this))
    window.quill = new Quill $qe[0],
      theme: 'snow'
      placeholder: this.placeholder

    $(this).parents('form').submit =>
      $(this).val($qe.html())
      return true
