class ProfilesController < ApplicationController

  include CasHelper

  layout 'security'

  def edit
    @profile = current_user.profile
  end

  def update
    current_user.profile.update params.require(:profile).permit!
    redirect_to edit_profile_path(cas_params)
  end



end
