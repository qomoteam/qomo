#= require jsPlumb
#= require jstree

window.plumb = {}

hightest_zIndex = 50
toolbox_offset = 0


get_pid = ->
  localStorage.getItem('pid')

set_pid = (value)->
  if value == null
    localStorage.removeItem 'pid'
  else
    localStorage.pid = value


init_cache = (forse=false)->
  if forse or not localStorage.boxes
    localStorage.boxes = JSON.stringify {}
  if forse or not localStorage.connections
    localStorage.connections = JSON.stringify []


cached_boxes = ->
  JSON.parse localStorage.boxes


cached_connections = ->
  JSON.parse localStorage.connections


load = (pid)->
  set_pid(pid)
  $.get Routes.pipeline(pid, {format: 'json'}), (data)->
    localStorage.boxes = data.boxes
    localStorage.connections = data.connections
    restore_workspace()


merge = (pid)->
  $.get Routes.pipeline(pid, {format: 'json'}), (data)->
    boxes = cached_boxes()

    new_boxes = JSON.parse(data.boxes)
    new_connections = JSON.parse(data.connections)

    for i of new_boxes
      new_box = new_boxes[i]
      new_id = App.guid()
      new_box.id = new_id
      boxes[new_id] = new_box
      for new_connection in new_connections
        new_connection.sourceId = new_id if new_connection.sourceId == i
        new_connection.targetId = new_id if new_connection.targetId == i

    save_cached_boxes(boxes)

    connections = cached_connections().concat new_connections
    save_cached_connections(connections)

    restore_workspace()


clean_workspace = ->
  init_cache(true)
  set_pid(null)
  $('#canvas .toolbox').remove()
  plumb.deleteEveryEndpoint()


restore_workspace = ->
  if get_pid()
    $.get Routes.pipeline(get_pid(), {simple: true, format: 'json'}), (pipeline) ->
      $('.pipeline-meta-title').html("#{pipeline.accession}: <strong>#{pipeline.title}</strong> (#{pipeline.updated_at})")
  boxes = cached_boxes()

  add_toolboxes boxes, ->
    connections = cached_connections()
    for connection in connections
      add_connection connection



add_connection = (connection)->
  sourceEp = eps[connection.sourceId][connection.sourceParamName]
  targetEp = eps[connection.targetId][connection.targetParamName]
  plumb.connect
    drawEndpoints: false
    source: sourceEp
    target: targetEp
  $("\##{connection.targetId}").find("input[name=#{connection.targetParamName}]").val('').prop 'disabled', true


save_cached_boxes = (boxes)->
  localStorage.boxes = JSON.stringify boxes


save_cached_connections = (connections)->
  localStorage.connections = JSON.stringify connections


cache_box = (bid, tid)->
  box = {}
  box.id = bid
  box.tid = tid
  box.values = {}
  boxes = cached_boxes()
  boxes[bid] = box
  save_cached_boxes boxes



update_zIndex = ($box, zIndex) ->
  hightest_zIndex += 2
  $box.css 'z-index', hightest_zIndex
  for ep in plumb.getEndpoints $box.attr('id')
    $(ep.canvas).css 'z-index', hightest_zIndex + 1


update_position = (bid, position) ->
  boxes = cached_boxes()
  boxes[bid].position = position
  save_cached_boxes boxes


cache_connection = (sourceId, sourceParamName, targetId, targetParamName)->
  connections = cached_connections()
  connections.push
    sourceId: sourceId
    sourceParamName: sourceParamName
    targetId: targetId
    targetParamName: targetParamName

  save_cached_connections connections


delete_connection = (sourceId, sourceParamName, targetId, targetParamName)->
  connections = cached_connections()
  for connection, i in connections
    if connection.sourceId == sourceId and connection.sourceParamName == sourceParamName and connection.targetId == targetId and connection.targetParamName == targetParamName

      connections.splice i, 1
      save_cached_connections(connections)

      $("\##{connection.targetId}").find("input[name=#{connection.targetParamName}]").val('').removeAttr 'disabled'
      break


window.eps = {}

add_toolboxes = (boxes, hook)->
  return if localStorage.boxes == '{}'

  boxes = []
  for k, v of cached_boxes()
    boxes.push v

  $.ajax
    method: 'POST'
    url: Routes.boxes_tools()
    data: JSON.stringify(boxes: boxes)
    contentType: 'application/json; charset=utf-8'
    success: (boxes_html) ->
      $(boxes_html).each ->
        box = cached_boxes()[this.id]
        init_box this, box.id, box.position
      hook()




add_toolbox = (bid, tid, position, box)->
  init_box box, bid, position


init_box = (box_html, bid, position)->
  $box = $(box_html)

  if position
    $box.css
      top: position.top
      left: position.left
  else
    $box.offset
      top: toolbox_offset
      left: toolbox_offset
    toolbox_offset += 30
    if toolbox_offset > 400
      toolbox_offset = 5
    update_position bid, $box.position()

  $('#canvas').append $box

  AJS.$("select", $box).auiSelect2()

  plumb.draggable $box,
    stop: ->
      update_position bid, $box.position()

  divHeight = $box.outerHeight()
  tdHeight = $box.find('td').outerHeight()
  titleHeight = $box.find('.titlebar').outerHeight()

  teps = {}

  for param, i in $box.find('.params .param')
    $param = $(param)

    $param.find('.value').each ->
      boxes = cached_boxes()
      paramName = $param.data('paramname')

      # When this is a new added tool, we should populate its default values first
      unless position
        boxes[bid].values[paramName] = if $(this).is(':checkbox') then this.checked else $(this).val()
        save_cached_boxes(boxes)

      value = boxes[bid].values[paramName]
      if $(this).is(':checkbox')
        this.checked = value
      else if $(this).is('select')
        App.setSelectValues this, value
        $(this).trigger 'chosen:updated'
      else
        $(this).val value

      # Open a file select dialog when click input component
      if $(this).hasClass('input')
        _this = $(this)
        window.filetree = null
        $(this).click ->
          did = App.guid()
          dia = dialog
            id: did
            title: 'Select File'
            content: $('#tpl-filetree').html()
            width: 700
            okValue: 'OK'
            ok: ->
              value = $(document.getElementById("content:#{did}")).find('.path').val()
              _this.val value
              _this.trigger 'change'
              return true
            cancelValue: 'Cancel'
            cancel: ->
          $(document.getElementById("content:#{did}")).find('.path').val _this.val()
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
            $(document.getElementById("content:#{did}")).find('.path').val e.selected.join(' ')


      $(this).change ->
        boxes = cached_boxes()
        value = $(this).val()

        if $(this).is(':checkbox')
          value = $(this).is(':checked')

        boxes[bid].values[paramName] = value

        save_cached_boxes(boxes)

    is_input = false
    if $param.hasClass 'input'
      is_input = true
    else if $param.hasClass 'output'
      is_input = false
    else
      continue

    y = (titleHeight+tdHeight*i + 20) / divHeight

    color =  unless is_input then "#558822" else "#225588"

    ep = plumb.addEndpoint bid,
      endpoint: 'Rectangle'
      anchor: [1, y, 1, 0]
      paintStyle:
        fillStyle: color
        width: 15
        height: 15
      isSource: not is_input
      isTarget: is_input
      maxConnections: 50

    ep.paramName = $param.find('input').attr 'name'

    teps[$param.find('input').attr('name')] = ep

  eps[bid] = teps

  update_zIndex $box
  $box.mousedown ->
    if ($box.css 'z-index') < hightest_zIndex
      update_zIndex $box

  $box.find('.close-toolbox').click ->
    remove_toolbox($box)

  plumb.repaint bid
  $box.bind 'DOMSubtreeModified', ->
    plumb.repaint bid


remove_toolbox = ($box)->
  bid = $box.attr 'id'
  boxes = cached_boxes()
  delete boxes[bid]

  save_cached_boxes(boxes)

  connections = cached_connections()
  for connection, i in connections
    continue unless connection
    if bid == connection.sourceId
      console.debug connection
      $("\##{connection.targetId}").find("input[name=#{connection.targetParamName}]").val('').prop 'disabled', false

    if bid in [connection.sourceId, connection.targetId]
      connections.splice i, 1
  save_cached_connections(connections)

  for ep in plumb.getEndpoints bid
    plumb.deleteEndpoint ep

  $box.remove()


populate_pform = ($form)->
  $form.find('#pipeline_boxes').val localStorage.boxes
  $form.find('#pipeline_connections').val localStorage.connections


within 'workspaces', 'show', ->
  $c = $('#content')
  window.onresize = ->
    $c.height($(window).height() - $c.offset().top)
  window.onresize()
  $c.layout()

  init_cache()

  # Save the pipeline in workspace
  $('.save').click ->
    if get_pid() != null
      $.get Routes.edit_pipeline(get_pid()), (data)->
        $form =$(data)
        populate_pform $form
        $form.ajaxSubmit dataType: 'json'
    else
      $.get Routes.new_pipeline(), (data)->
        dia = dialog
          title: 'Save pipeline'
          content: data
          width: 700
          okValue: 'Save'
          ok: ->
            $form = $('#form-pipeline')
            populate_pform $form
            $form.ajaxSubmit success: (pid) ->
              set_pid(pid)
            return true
          cancelValue: 'Cancel'
          cancel: ->

        dia.showModal()

    return false


  $('.reset').click clean_workspace


  # Click the tool category bar in left sidebar
  $('#tools-selector h5').click ->
    $this = $(this)
    $ul = $(this).next('ul')
    $i = $(this).find('i')
    if $ul.is(':visible')
      $i.removeClass('fa-folder-open').addClass('fa-folder')
      $ul.slideUp 200, ->
        $this.css 'border-bottom-width', '0'
    else
      $i.removeClass('fa-folder').addClass('fa-folder-open')
      $this.css 'border-bottom-width', '1px'
      $ul.slideDown 200


  updateJobStatus = ->
    $('.jobs').load $('.jobs').data('url')


  updateJobStatus()
  setInterval updateJobStatus, 10000

  $('.job-summary .refresh').click ->
    updateJobStatus()
    return false


  jsPlumb.ready ->
    window.plumb = jsPlumb.getInstance
      DragOptions:
        cursor: 'pointer'
        zIndex: 2000
      ConnectionOverlays: [
        [
          "Arrow",
          location: 0.5,
          length: 20
        ]
      ]
      PaintStyle:
        strokeStyle: '#456'
        lineWidth: 6


    plumb.bind 'click', (c)->
      delete_connection c.sourceId, c.endpoints[0].paramName, c.targetId, c.endpoints[1].paramName

      plumb.detach c
      return true


    plumb.bind 'beforeDrop', (info)->
      sourceParamName = info.connection.endpoints[0].paramName
      targetParamName = info.dropEndpoint.paramName
      cache_connection info.sourceId, sourceParamName, info.targetId, targetParamName


      $("\##{info.targetId}").find("input[name=#{targetParamName}]").val('').prop 'disabled', true
      return true

    if typeof(_action) != 'undefined'
      eval "#{_action}('#{_pid}')"
    else
      restore_workspace()


    #Click link in left sidebar tool list
    $('#tools-selector a.tool-link').click ->
      tid = this.dataset.tid
      $.ajax
        method: 'POST'
        url: Routes.boxes_tools()
        data: JSON.stringify(boxes: [{tid: tid}])
        contentType: 'application/json; charset=utf-8'
        success: (box) ->
          cache_box $(box).attr('id'), $(box).data('tid')
          add_toolbox $(box).attr('id'), $(box).data('tid'), null, $(box)

      return false


    $('#tools-selector a.tool-help').click ->
      dia = dialog
        title: "Help: #{$(this).data 'title'}"
        width: 500
      dia.show()
      $.get this.href, (data) ->
        dia.content data
      return false


    # Submit current pipeline to job engine
    $('#canvas-toolbar .run').click ->
      $.post this.href,
        boxes: localStorage.boxes
        connections: localStorage.connections
      , (data) ->
        if data.success
          alert("Pipeline submitted.")
          updateJobStatus()
        else
          alert("Pipeline has an error: #{data.content}")
      false

    $('#canvas-toolbar .load').click ->
      $.get Routes.my_pipelines(inline: true), (data) ->
        dia = dialog
          content: data
          title: 'Load Pipeline'
          width: 800
        dia.show()


