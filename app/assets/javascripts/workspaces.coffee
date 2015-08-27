within 'workspaces', 'show', ->
  window.onresize = ->
    $('#main').height($(window).height() - $('#main').offset().top)
  window.onresize()
  $('#main').layout()
