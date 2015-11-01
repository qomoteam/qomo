within 'workspaces', 'show', ->
  $c = $('#content')
  window.onresize = ->
    $c.height($(window).height() - $c.offset().top)
  window.onresize()
  $c.layout()

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
