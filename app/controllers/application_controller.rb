class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :reg_gon_attrs

  private

  def reg_gon_attrs
    gon.controller = params[:controller]
    gon.action = params[:action]
  end

end
