#= require js-routes
#= require jquery
#= require jquery-ujs
#= require artDialog
#= require jquery-form
#= require patch
#= require aui

class GUID
  s4: ->
    Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)

  create: () ->
    "#{@s4()}#{@s4()}-#{@s4()}-#{@s4()}-#{@s4()}-#{@s4()}#{@s4()}#{@s4()}"

tpl_fileselector = "<form class='aui'>
<input class='path text' value='' />
  <div class='tree'></div>
</form>"

window.App =
  scopes: {}

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
    $e.click ->
      did = App.guid()
      dia = dialog
        id: did
        title: 'Select File'
        content: tpl_fileselector
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
      dia.showModal()

      $(document.getElementById("content:#{did}")).find('.tree').jstree(
        core:
          animation: 0
          themes:
            stripes: true
          data:
            url: (node) ->
              Routes.datastore_filetree()
            data: (node) ->
              'dir' : if node.id == '#' then '' else node.id
      ).on 'changed.jstree', (je, e) ->
        # Use comma to seqerate multiple inputs
        $(document.getElementById("content:#{did}")).find('.path').val e.selected.join(',')


$ ->
  AJS.$('select').auiSelect2()
  $('.logout').click ->
    localStorage.clear()
    true


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
