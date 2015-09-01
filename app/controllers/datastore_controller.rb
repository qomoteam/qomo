class DatastoreController < ApplicationController
  def show
    @path = params[:path] || ''
    @files = current_user.datastore.list(@path)
    gon.pwd = @path
    render 'dir'
  end

  def mkdir
    current_user.datastore.mkdir! params[:dirpath]
    render json: {success: true}
  end

end
