class DatastoreController < ApplicationController
  def show
    @pwd = params[:path] || ''
    @files = current_user.datastore.list(@pwd)
    gon.pwd = @pwd
    render 'directory'
  end

  def mkdir
    current_user.datastore.mkdir! params[:dirpath]
    render json: {success: true}
  end

  def trash
    puts params[:path]
    current_user.datastore.trash! params[:path]
    render json: {success: true}
  end

end
