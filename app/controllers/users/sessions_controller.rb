class Users::SessionsController < Devise::SessionsController
  # before_filter :configure_sign_in_params, only: [:create]

  include Cas

  prepend_before_action :valify_captcha!, only: [:create]

  def guest_signin
    user = User.create_guest
    flash[:notice] = "Sign in as guest user #{user.username}, temp password 123456"
    user.remember_me!
    sign_in_and_redirect user
  end

  #GET /resource/sign_in
  def new
    @page_title = 'BIGD CAS Login'
    super
  end

  # POST /resource/sign_in
  def create
    # Trapped in CAS protocal
    if params[:service].present?
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
      redirect_to new_user_session_path, alert: 'Invalid captcha code'
      return
    end
    true
  end

end
