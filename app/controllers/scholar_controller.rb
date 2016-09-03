class ScholarController < ApplicationController
  def show
    @user = User.find_by_username params[:username]
    @page_title = @user.displayed_name
  end
end
