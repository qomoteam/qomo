module ApplicationHelper

  def active_class(p)
    params[:controller] == p ? 'active' : ''
  end


  def revision_tag
    Config.revision
  end

end
