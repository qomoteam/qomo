within 'workspaces', 'show', ->
  $c = $('#content')
  window.onresize = ->
    $c.height($(window).height() - $c.offset().top)
  window.onresize()
  $c.layout()
