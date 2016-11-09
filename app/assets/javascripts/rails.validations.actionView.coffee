window.ClientSideValidations.formBuilders['ActionView::Helpers::FormBuilder'] =
  add: (element, settings, message) ->
    element.addClass('field_with_errors')
    if element.parents('form').hasClass('top-label')
      $ctl = $("label[for=#{element.attr('id')}]")
      $ctl.find('span.error-message').remove()
      $ctl.append("<span class='error-message'>#{message}</span>")
    else
      $ctl = element
      $ctl.next('span.error-message').remove()
      $ctl.after("<span class='error-message'>#{message}</span>")


  remove: (element, settings) ->
    $(element).removeClass('field_with_errors')
    if element.parents('form').hasClass('top-label')
      $ctl = $("label[for=#{element.attr('id')}]")
      $ctl.find('span.error-message').remove()
    else
      $ctl = element
      $ctl.next('span.error-message').remove()
