class DatastoreController < ApplicationController
  def show
    @path = params[:path] || ''
    @files = current_user.datastore.list(@path)
    render 'dir'
  end
end
