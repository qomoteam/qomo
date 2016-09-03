class Admin::UsersController < Admin::ApplicationController

  def index
    @users = User.all
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

end
