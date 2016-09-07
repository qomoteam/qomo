class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :reg_gon_attrs

  before_action :configure_permitted_parameters, if: :devise_controller?

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound,
                ActionController::RoutingError,
                AbstractController::ActionNotFound,
                ActionController::MethodNotAllowed do |exception|

      # Put loggers here, if desired.

      redirect_to four_oh_four_path
    end
  end

  class NotFound < StandardError
  end

  class UnAuthorized < StandardError
  end

  rescue_from NotFound, ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from UnAuthorized, with: :handle_unauthorized

  def not_found
    raise NotFound.new
  end

  def unauthorized
    raise UnAuthorized.new
  end

  private

  def handle_not_found
    render status: :not_found, template: 'errors/not_found', formats: [:html]
  end

  def handle_unauthorized
    render status: :unauthorized, template: 'errors/not_authorized', formats: [:html]
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:username, :email, :password, :password_confirmation, :first_name, :last_name)
    end
  end

  def reg_gon_attrs
    gon.controller = params[:controller]
    gon.action = params[:action]
    gon.user_signed_in = user_signed_in?
    gon.guest = user_signed_in? ? current_user.has_role?(:guest) : true
    gon.uid = current_user.id if user_signed_in?
  end

end
