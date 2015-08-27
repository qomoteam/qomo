module ApplicationHelper

  def active_class(p)
    params[:controller] == p ? 'active' : ''
  end

end
