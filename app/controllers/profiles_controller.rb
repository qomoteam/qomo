class ProfilesController < ApplicationController

  def edit
    @profile = current_user.profile
  end

  def update
    current_user.profile.update params.require(:profile).permit!
    redirect_to action: 'edit'
  end

end
