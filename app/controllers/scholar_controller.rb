class ScholarController < ApplicationController

  before_action :authenticate_user!, except: [:show]

  def show
    @user = User.find_by_username params[:username]
    @page_title = @user.profile.displayed_name
  end

end
