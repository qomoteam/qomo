module ApplicationHelper

  def active_class(controller, action=nil, cls='active')
    params[:controller] == controller and params[:action] == (action || params[:action]) ? cls : ''
  end


  def revision_tag
    Config.revision
  end

end
