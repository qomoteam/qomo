class Admin::UsersController < Admin::ApplicationController

  def index
    @users = User.without_role(:guest).order(:username).page params[:page]
  end

  def show
    @user = User.find params[:id]
  end

  def destroy
    user = User.find(params[:id])
    user.destroy!
    redirect_to admin_users_path
  end

  def destroy_expired
    User.expired_guests.each { |user| user.destroy! }
    redirect_to admin_users_path
  end

  def lock
    user = User.find params[:id]
    user.lock_access!
    redirect_back fallback_location: admin_users_path
  end

  def unlock
    user = User.find params[:id]
    user.unlock_access!
    redirect_back fallback_location: admin_users_path
  end

  def search
    @users = User.without_role(:guest).order(:username)
                 .where('LOWER(username) LIKE :q OR LOWER(email) LIKE :q', {q: "%#{params[:q].downcase}%"}).page params[:page]
    render 'index'
  end

end
