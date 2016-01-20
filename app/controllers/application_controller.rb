class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :reg_gon_attrs

  before_filter :configure_permitted_parameters, if: :devise_controller?

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound,
                ActionController::RoutingError,
                AbstractController::ActionNotFound,
                ActionController::MethodNotAllowed do |exception|

      # Put loggers here, if desired.

      redirect_to four_oh_four_path
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :first_name, :last_name) }
  end

  def reg_gon_attrs
    gon.controller = params[:controller]
    gon.action = params[:action]
    gon.user_signed_in = user_signed_in?
    gon.guest = user_signed_in? ? current_user.has_role?(:guest) : true
  end

end
