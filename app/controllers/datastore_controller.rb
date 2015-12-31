class DatastoreController < ApplicationController
  before_action :authenticate_user!, except: [:filetree]

  def show
    @meta = current_user.datastore.get path
    unless @meta
      render 'not_found'
      return
    end

    gon.path = path

    if @meta.directory?
      @files = current_user.datastore.list path
    else
      @content = @meta.read
    end

    render "datastore/viewer/#{@meta.type.tpl}"
  end


  def share
    record = Filerecord.find_or_create_by(name: File.basename(path), path: path, owner_id: current_user.id)

    record.shared = true
    record.save

    render json: {success: true}
  end


  def unshare
    Filerecord.where(path: path, owner_id: current_user.id).each do |record|
      record.shared = false
      record.save
    end

    render json: {success: true}
  end


  def clear
    current_user.datastore.list(path).each do |f|
      if f.name.start_with?('job-') and f.directory? and current_user.datastore.list(f.path).size == 0
        f.delete!
        Filerecord.destroy_all path: f.path, owner_id: current_user.id
      end
    end

    redirect_to datastore_path(path)
  end


  def path
    params[:path] || ''
  end


  def filetree
    files_tree = {}
    if user_signed_in?
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
    end

    render json: files_tree
  end


  def mkdir
    current_user.datastore.mkdir! params[:path]
    render json: {success: true}
  end


  def trash
    current_user.datastore.trash! params[:path]
    Filerecord.destroy_all path: params[:path], owner_id: current_user.id
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
