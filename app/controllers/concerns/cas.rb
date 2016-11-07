module Cas
  extend ActiveSupport::Concern

  included do
    prepend_before_action :before_login, :only => [:new]

    layout :resolve_layout

    def before_login
      if params[:service] and user_signed_in?
        cas_login
      end
    end

    def cas_login
      service = params[:service]
      if user_signed_in?
        self.resource = current_user
      else
        self.resource = warden.authenticate(auth_options)
      end

      if resource
        # Guests are not allowed to sign in with CAS service
        if resource.is_guest?
          flash[:alert] = 'Guests are not allowed to sign in with CAS service'
          redirect_back fallback_location: root_path
        else
          ticket = "ST-#{SecureRandom.uuid}"
          Rails.cache.write(ticket, resource.id, namespace: :cas, expires_in: 30.minutes)
          redirect_to service.add_param(ticket: ticket)
        end
      else
        flash[:alert] = 'Invalid Login or password.'
        redirect_back fallback_location: root_path
      end
    end

    def service_validate
      user_id = Rails.cache.read(params[:ticket], namespace: :cas)
      if user_id
        @success = true
        @user = User.find user_id
      else
        @success = false
      end
      render 'cas/validate'
    end

    def cas_logout
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      redirect_to params[:service]
    end


    private

    def resolve_layout
      if cas_request?
        'bigd'
      else
        'application'
      end
    end

    def cas_request?
      params[:service].present?
    end
  end

end
