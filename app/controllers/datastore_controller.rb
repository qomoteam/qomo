class DatastoreController < ApplicationController
  def show
    path = params[:path] || ''
    @meta = current_user.datastore.get path
    unless @meta
      render 'not_found'
      return
    end

    gon.path = @path
    if @meta.directory?
      @files = current_user.datastore.list path
    else
      @content = current_user.datastore.read path
    end

    render "datastore/viewer/#{@meta.kind}"
  end


  def mkdir
    current_user.datastore.mkdir! params[:dirpath]
    render json: {success: true}
  end


  def trash
    current_user.datastore.trash! params[:path]
    render json: {success: true}
  end


  def upload
    if request.post?
      current_user.datastore.save! File.join(params[:dir], params[:filename]), params[:file].tempfile
      render json: {success: true}
    else
      gon.dir = params[:dir] || ''
      gon.token = form_authenticity_token
    end
  end


  def download
    path = params[:path]
    send_file current_user.datastore.apath(path)
  end

end
