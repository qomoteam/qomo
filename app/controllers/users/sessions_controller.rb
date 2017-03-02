class Users::SessionsController < Devise::SessionsController
  # before_filter :configure_sign_in_params, only: [:create]

  prepend_before_action :valify_captcha!, only: [:create]

  layout 'security'

  include Cas
  include CasSession

  def guest_signin
    user = User.create_guest
    flash[:notice] = "Sign in as guest user #{user.username}, temp password 123456"
    user.remember_me!
    sign_in_and_redirect user
  end

  #GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    # Trapped in CAS protocal
    if cas_request?
      cas_login
    else
      super
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end


  private

  def valify_captcha!
    unless verify_rucaptcha?
      if cas_request?
        url = cas_login_path(service: params[:service])
      else
        url = new_user_session_path
      end
      redirect_to url, alert: 'Invalid captcha code'
      return
    end
    true
  end

end
