class ProfilesController < ApplicationController

  include CasHelper

  layout :choose_layout

  def edit
    @profile = current_user.profile
  end

  def update
    current_user.profile.update params.require(:profile).permit!
    if cas_request?
      redirect_to edit_profile_path(cas_request: cas_request)
    else
      redirect_to edit_profile_path
    end
  end


  private

  def choose_layout
    cas_request? ? 'bigd' : 'application'
  end

end
