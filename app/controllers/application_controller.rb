class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :reg_gon_attrs

  before_action :configure_permitted_parameters, if: :devise_controller?

  class NotFound < StandardError
  end

  class UnAuthorized < StandardError
  end

  rescue_from NotFound,
              ActiveRecord::RecordNotFound,
              ActionController::RoutingError,
              AbstractController::ActionNotFound,
              ActionController::MethodNotAllowed,
              with: :handle_not_found

  rescue_from UnAuthorized, CanCan::AccessDenied, with: :handle_unauthorized

  def not_found
    raise NotFound.new
  end

  def unauthorized
    raise UnAuthorized.new
  end

  def set_page_title(title)
    @page_title = title
  end

  include Cas

  def after_sign_in_path_for(resource_or_scope)
    if service.present?
      ticket = "ST-#{SecureRandom.uuid}"
      Rails.cache.write(ticket, current_user.id, namespace: :cas, expires_in: 30.minutes)
      params[:service].add_param(ticket: ticket)
    elsif cas_request?
      edit_profile_path(cas_request: true)
    else
      stored_location_for(resource_or_scope) || signed_in_root_path(resource_or_scope)
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path(cas_params)
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
      u.permit(:username, :email, :password, :password_confirmation, :term_of_service, :profile_attributes => [:first_name, :last_name])
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
