class Users::ProfilesController < ApplicationController

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.update params.require(:user).permit!
    redirect_to action: 'edit'
  end

end
