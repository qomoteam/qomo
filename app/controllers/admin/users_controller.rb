class Admin::UsersController < Admin::ApplicationController
  def index
    @users_grid = initialize_grid User
  end

  def show
  end
end
