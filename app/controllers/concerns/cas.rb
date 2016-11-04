module Cas
  extend ActiveSupport::Concern

  included do
    prepend_before_action :before_login, :only => [:new]

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
        ticket = "ST-#{SecureRandom.uuid}"
        Rails.cache.write(ticket, resource.id, namespace: :cas, expires_in: 1000)
        redirect_to service.add_param(ticket: ticket)
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
  end

end
