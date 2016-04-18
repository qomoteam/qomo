class Admin::UsersController < Admin::ApplicationController
  def index
    @users_grid = initialize_grid User
  end

  def show
    @user = User.find params[:id]
  end

  def destroy
    user = User.find(params[:id])
    FileUtils.rm_rf Datastore.home_dir(user.id, Config.dir_users)
    user.destroy
    redirect_to admin_users_path
  end

end
