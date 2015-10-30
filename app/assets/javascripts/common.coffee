#= require js-routes
#= require jquery
#= require jquery-ujs
#= require patch
#= require aui

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
