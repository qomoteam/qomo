class Admin::ApplicationController < ApplicationController
  layout 'admin'

  before_action :authenticate_admin

  private
  def authenticate_admin
    unless current_user.has_role? :admin
      redirect_to root_path
    end
  end

end
