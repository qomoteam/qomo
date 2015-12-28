class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :reg_gon_attrs

  before_filter :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :first_name, :last_name) }
  end

  def reg_gon_attrs
    gon.controller = params[:controller]
    gon.action = params[:action]
    gon.user_signed_in = user_signed_in?
  end

end
