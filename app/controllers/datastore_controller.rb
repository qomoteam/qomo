class DatastoreController < ApplicationController
  def show
    path = params[:path] || ''
    @meta = current_user.datastore.get path
    @files = current_user.datastore.list path
    gon.path = @path
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
