class DatastoreController < ApplicationController
  
  def show
    path = params[:path] || ''
    @meta = current_user.datastore.get path
    unless @meta
      render 'not_found'
      return
    end

    gon.path = path

    if @meta.directory?
      @files = current_user.datastore.list path
    else
      @content = current_user.datastore.read path
    end

    render "datastore/viewer/#{@meta.kind}"

  end

  def filetree
    @dir = params['dir'] || ''
    @files = current_user.datastore.list @dir

    files_tree = @files.collect do |e|
      {
          text: e.name,
          id: e.path,
          children: e.directory?,
          icon: e.directory? ? 'fa fa-folder' : 'fa fa-file-o'
      }
    end
    render json: files_tree
  end


  def mkdir
    current_user.datastore.mkdir! params[:path]
    render json: {success: true}
  end


  def trash
    current_user.datastore.trash! params[:path]
    render json: {success: true}
  end


  def mv
    current_user.datastore.mv! params[:src], params[:dest]
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
