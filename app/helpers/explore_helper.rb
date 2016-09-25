module ExploreHelper
  def explore_active_class(action)
    if params[:action] == action
      'aui-button-primary'
    else
      ''
    end
  end
end
