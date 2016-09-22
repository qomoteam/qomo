#= require jsPlumb
#= require jstree

window.plumb = {}

hightest_zIndex = 50
toolbox_offset = 0

sourceColor = '#558822'

targetColor = '#225588'

MAX_CONNECTIONS = 25

get_pid = ->
  localStorage.getItem('pid')

set_pid = (value)->
  if value == null
    localStorage.removeItem 'pid'
  else
    localStorage.pid = value


init_cache = (forse = false)->
  if forse or not localStorage.boxes
    localStorage.boxes = JSON.stringify {}
  if forse or not localStorage.connections
    localStorage.connections = JSON.stringify []
  if forse or not localStorage.params
    set_pipeline_params null


cached_boxes = ->
  JSON.parse localStorage.boxes


cached_connections = ->
  JSON.parse localStorage.connections


load = (pid)->
  set_pid(pid)
  $.get Routes.pipeline(pid, {format: 'json'}), (data)->
    localStorage.boxes = JSON.stringify data.boxes
    localStorage.connections = JSON.stringify data.connections
    set_pipeline_params data.params
    restore_workspace()


merge = (pid)->
  $.get Routes.pipeline(pid, {format: 'json'}), (data)->
    boxes = cached_boxes()

    new_boxes = data.boxes
    new_connections = data.connections

    set_pipeline_params data.params

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
  $('#boxes-props').html('')
  reset_ptitle()

get_ptitle = ->
  $('.pipeline-meta-title').data('title')

reset_ptitle = () ->
  $('.pipeline-meta-title').data('title', '')
  $('.pipeline-meta-title a').remove()


restore_workspace = ->
  App.freeze_canvas()
  if get_pid()
    $.ajax
      method: 'get'
      url: Routes.pipeline(get_pid(), data: {simple: true, format: 'json'})
      success: (pipeline) ->
        purl = Routes.pipeline(get_pid())
        $('.pipeline-meta-title').data('title', pipeline.title).html(
          "<a href='#{purl}'><strong>#{pipeline.title}</strong></a>"
        )
      error: ->
        clean_workspace()
  boxes = cached_boxes()

  if $.isEmptyObject(cached_boxes())
    App.unfreeze_canvas()
  else
    add_toolboxes boxes, ->
      connections = cached_connections()
      for connection in connections
        add_connection connection
      App.unfreeze_canvas()


add_connection = (connection)->
  sourceEp = eps[connection.sourceId][connection.sourceParamName]
  targetEp = eps[connection.targetId][connection.targetParamName]
  plumb.connect
    drawEndpoints: false
    source: sourceEp
    target: targetEp
  $(".box-props[data-bid=#{connection.targetId}] .param[data-paramname=\"#{connection.targetParamName}\"] input").val('').prop('disabled', true)


save_cached_boxes = (boxes)->
  localStorage.boxes = JSON.stringify boxes


save_cached_connections = (connections)->
  localStorage.connections = JSON.stringify connections


cache_box = (bid, tool_id)->
  box = {}
  box.id = bid
  box.tool_id = tool_id
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
    success: (response) ->
      boxes_html = parse_boxes(response)
      handle_props(response)
      $(boxes_html).each ->
        box = cached_boxes()[this.id]
        init_box this, box.id, box.position
      hook()
    error: (response) ->
      clean_workspace()
      App.unfreeze_canvas()
      notie.alert(3, 'An error occured when loading workspace pipeline')


add_toolbox = (bid, tool_id, position, box)->
  init_box box, bid, position


tpl_param_dialog = (label, pname) ->
  "<h4>Export as Pipeline Param:</h4>" +
    "<form class='aui'>" +
    "<div class='field-group'>" +
    "<label>#{label} =></label><input class='text medium-field paramiterize' value='#{pname}'></div></form>"

add_pipeline_param = (paramName, pname, box_id) ->
  params = get_pipeline_params()
  if pname
    e = {name: paramName, label: pname, box_id: box_id}
    added = false
    # Avoid redudant pipeline params with same paramName
    params = _.map params, (p) ->
      if p['name'] == paramName and p['box_id'] == box_id
        added = true
        e
      else
        p
    unless added
      params.push {name: paramName, label: pname, box_id: box_id}
  else
    params = _.reject params, (p) -> p['name'] == paramName and p['box_id'] == box_id

  set_pipeline_params params
# END add_pipeline_param(paramName, pname, tool_id)

get_pipeline_params = ->
  JSON.parse localStorage.params

set_pipeline_params = (params) ->
  params = params || []
  localStorage.params = JSON.stringify params


parse_boxes = (response) -> $(response).filter ()-> $(this).hasClass('toolbox')

handle_props = (response) ->
  $props = $(response).filter ()-> $(this).hasClass('box-props')
  add_box_props($props)

add_box_props = ($props) ->
  $('#boxes-props').prepend($props)

# Display tool usage in right panel
show_tool_usage = (tid) ->
  $.get Routes.help_tool(tid), (html) ->
    $('#boxes-props .tool-usage').html(html)
    AJS.tabs.change $('a[href="#boxes-props"]')


# Display tool properties in right panel
show_box_prop = (bid) ->
  hide_box_props()
  box_prop(bid).show()
  AJS.tabs.change $('a[href="#boxes-props"]')

box_prop = (bid) ->
  $("#box-props-#{bid}")

highlight_box = (bid) ->
  $('.toolbox').removeClass('highlight')
  box = $("##{bid}")
  box.addClass('highlight')
  tid = box.data('tid')
  show_tool_usage(tid)
  show_box_prop(bid)

hide_box_props = ->
  $('#boxes-props .box-props').hide()

unhighlight_toolbox = ->
  $('.toolbox.highlight').removeClass('highlight')

init_box = (box_html, bid, position)->
  plumb.batch ->
    $box = $(box_html)
    $props = box_prop(bid)

    tid = $box.data('tid')

    $box.click ->
      highlight_box(bid)

    $box.find('input').click (e)->
      $(this).focus()

    if position and position.top > 0 and position.left > 0
      $box.css
        top: position.top
        left: position.left
    else
      $box.offset
        top: toolbox_offset
        left: toolbox_offset
      toolbox_offset += 30
      if toolbox_offset > 500
        toolbox_offset = 5
      update_position bid, $box.position()

    $('#canvas .jtk-surface-canvas').append $box
    renderer.ingest(document.getElementById(bid))

    AJS.$("select", $props).auiSelect2()

    plumb.draggable $box,
      stop: ->
        update_position bid, $box.position()

    on_param_click = ->
      label = this.innerText
      paramName = $(this).parents('tr').data('paramname')
      plabel = ''
      for p in get_pipeline_params()
        if p['box_id'] == bid and p['name'] == paramName
          plabel = p['label']

      content = tpl_param_dialog(label, plabel)
      dia = dialog
        id: bid
        title: "Param: #{label}"
        content: content
        width: 500
        okValue: 'Save'
        ok: ->
          pname = $(document.getElementById("content:#{bid}")).find('.paramiterize').val()
          add_pipeline_param(paramName, pname, bid)
          return true
        cancelValue: 'Cancel'
        cancel: ->
      dia.showModal()

    $box.find('label.param-label').click on_param_click
    box_prop(bid).find('label.param-label').click on_param_click

    divHeight = $box.outerHeight()
    titleHeight = $box.find('.titlebar').outerHeight()
    tableMarginTop = parseInt($box.find('table.params').css('margin-top').replace("px", ""))

    gy = titleHeight + tableMarginTop

    teps = {}

    for param, i in $props.find('.params .param')
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
        else
          $(this).val value

        # Open a file select dialog when click input component
        if $(this).hasClass('input')
          App.bindFileSelector this

        $(this).change ->
          boxes = cached_boxes()
          value = $(this).val()

          if $(this).is(':checkbox')
            value = $(this).is(':checked')

          boxes[bid].values[paramName] = value
          save_cached_boxes(boxes)

    for param, i in $box.find('.params .param')
      $param = $(param)
      is_input = false
      is_output = false
      if $param.hasClass 'input'
        is_input = true
        is_output = false
      else if $param.hasClass 'output'
        is_input = false
        is_output = true

      trHeight = $param.outerHeight()

      if is_input or is_output
        y = (gy + trHeight / 2 + (i + 1) * 2 ) / divHeight
        color = unless is_input then "#558822" else "#225588"
        ep = plumb.addEndpoint bid,
          anchor: [1, y, 1, 0]
          paintStyle:
            width: 10
            height: 10
            fillStyle: color
          isSource: not is_input
          isTarget: is_input
          maxConnections: MAX_CONNECTIONS


        ep.paramName = $param.data 'paramname'
        teps[ep.paramName] = ep

      gy += trHeight
    # END: for param, i

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

  box_prop(bid).remove()

  params = []
  for p in get_pipeline_params()
    if p['box_id'] != bid
      params.push(p)
  set_pipeline_params params

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
# END remove_toolbox($box)


populate_pform = ($form)->
  $form.find('#pipeline_boxes').val localStorage.boxes
  $form.find('#pipeline_connections').val localStorage.connections
  $form.find('#pipeline_params').val localStorage.params


canvas_resize = ->
  $("#canvas").css(height: $('#content').height() - $('#canvas-toolbar').height() - 1)

within 'workspaces', 'show', ->
  $c = $('#content')
  window.onresize = ->
    $c.height($(window).height() - $c.offset().top)
    canvas_resize()

  window.onresize()

  $c.layout
    west:
      size: 250
    east:
      size: 388

  canvas_resize()

  init_cache()

  # Save the pipeline in workspace
  $('.save').click ->
    if get_pid() != null
      $.ajax
        url: Routes.pipeline(get_pid(), {format: 'json'})
        method: 'PATCH'
        data:
          'pipeline[connections]': localStorage.connections
          'pipeline[boxes]': localStorage.boxes
          'pipeline[params]': localStorage.params
        success: ->
          notie.alert(1, 'Pipeline saved')
        error: ->
          notie.alert(3, 'An error occured when save pipeline')
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
              notie.alert(1, 'Pipeline saved')
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


  if gon.user_signed_in
    # TODO move to `App` namespace
    window.updateJobStatus = ->
      $('#job-summary .summary-content').load Routes.summary_jobs()


    updateJobStatus()

  $('#job-summary .refresh').click ->
    updateJobStatus()
    return false

  jsPlumbToolkit.ready ->
    window.plumb = jsPlumb.getInstance
      DragOptions:
        cursor: 'pointer'
        zIndex: 2000
      ConnectionOverlays: [
        [
          'Arrow',
          location: 0.5,
          width: 12,
          length: 12
        ]
      ]
      Connector: ['Flowchart', {stub: '20'}]
      Endpoint: 'Rectangle'
      EndpointHoverStyle:
        fillStyle: 'orange'
      PaintStyle:
        gradient:
          stops:
            [
              [0, sourceColor],
              [1, targetColor]
            ]
        strokeStyle: targetColor
        lineWidth: 3
      Container: 'canvas'

    window.renderer = jsPlumbToolkit.Support.ingest jsPlumb: plumb

    plumb.bind 'click', (c)->
      delete_connection c.sourceId, c.endpoints[0].paramName, c.targetId, c.endpoints[1].paramName
      $(".box-props[data-bid=#{c.targetId}] .param[data-paramname=#{c.endpoints[1].paramName}] input").prop('disabled', false)
      plumb.detach c

      return true


    plumb.bind 'beforeDrop', (info)->
      sourceParamName = info.connection.endpoints[0].paramName
      targetParamName = info.dropEndpoint.paramName
      cache_connection info.sourceId, sourceParamName, info.targetId, targetParamName

      $(".box-props[data-bid=#{info.targetId}] .param[data-paramname=#{targetParamName}] input").val('').prop('disabled', true)

      return true

    if typeof(_action) != 'undefined'
      eval "#{_action}('#{_pid}')"
    else
      restore_workspace()


    # Click tool link in left sidebar tool list
    $('#tools-selector a.tool-link').click ->
      tool_id = this.dataset.tid
      $.ajax
        method: 'POST'
        url: Routes.boxes_tools()
        data: JSON.stringify(boxes: [{tool_id: tool_id}])
        contentType: 'application/json; charset=utf-8'
        success: (response) ->
          $box = parse_boxes(response)
          handle_props(response)

          cache_box $box.attr('id'), $box.data('tid')
          add_toolbox $box.attr('id'), $box.data('tid'), null, $box
        error: (response) ->
          notie.alert(3, "An error occured when add tool into workspace")
      return false


    $('#tools-selector a.tool-help').click ->
      tid = $(this).data 'tid'
      show_tool_usage(tid)
      hide_box_props()
      unhighlight_toolbox()
      return false


    # Submit current pipeline to job engine
    $('#canvas-toolbar .run').click ->
      if $.isEmptyObject(cached_boxes())
        notie.alert 3, 'Empty workspace, nothing to run.'
      else
        now = new Date()
        if get_pid()
          defaultJobName = "#{get_ptitle()} #{now.getHours()}#{now.getMinutes()}"
        else
          defaultJobName = "Untitled Job #{now.getHours()}#{now.getMinutes()}"
        notie.input {
          type: 'text'
          placeholder: "Job name, default: #{defaultJobName}"
        }, 'Please enter a job name:', 'Submit', 'Cancel',
          (jobName) ->
            jobName = jobName || defaultJobName
            $.ajax
              url: Routes.run_workspace()
              type: 'POST'
              data:
                name: jobName
                boxes: localStorage.boxes
                connections: localStorage.connections
              success: (result) ->
                if result.success
                  msg = "Pipeline submitted."
                  if gon.guest
                    msg += "<br> Guest user will be restricted to use very limited resources."
                  notie.alert(1, msg, 1)
                  updateJobStatus()
                  AJS.tabs.change('a[href="#job-summary"]')
                else
                  msg = 'Pipeline param error <ul>'
                  for error in result.errors
                    toolName = $('#' + error.box_id).find('.titlebar .title').text()
                    msg += "<li>Param '#{error.param}' of tool #{toolName}: #{error.msg}</li>"
                  msg += '</ul>'
                  notie.alert(3, msg)
                  hboxId = result.errors[0].box_id
                  hparam = result.errors[0].param
                  highlight_box(hboxId)
              error: (data) ->
                alert("Pipeline has an error: #{data.content}")
      false


    # Load or merge one's own pipeline into current workspace
    $('#canvas-toolbar .load').click ->
      $.get Routes.my_pipelines(inline: true), (data) ->
        dia = dialog
          content: data
          title: 'Load Pipeline'
          width: 900
        dia.show()

    $('#tools-selector .search').keyup ->
      q = this.value.toLowerCase()
      hl = _.each $('#tools-selector a.tool-link'), (toollink) ->
        if toollink.textContent.toLowerCase().indexOf(q) == -1
          console.debug $(toollink).parents('li')
          $(toollink).parent().hide()
        else
          $(toollink).parent().show()


    $(document).on 'click', '.delete-job-summary', ->
      self = this
      console.debug self.href
      notie.confirm 'Are you sure want to delete this job?', 'Yes', 'Cancel', ->
        $.ajax
          url: self.href
          method: 'delete'
          success: ->
            $(self).parents('table.job').remove()
      return false


