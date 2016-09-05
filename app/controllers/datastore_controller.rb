class DatastoreController < ApplicationController

  LIBRARY_ID = '__dataset__library__'

  before_action :authenticate_user!, except: [:filetree]

  def datastore
    uid = params[:uid] || current_user.id
    Datastore.new uid, Config.dir_users
  end


  def show
    @meta = datastore.get path

    unless @meta
      render 'not_found'
      return
    end

    if params[:uid] and
        params[:uid] != current_user.id and
        !Filerecord.shared?(params[:uid], @meta.path)
      render 'not_found'
      return
    end

    gon.path = path

    if @meta.directory?
      @files = datastore.list path
    else
      @content = @meta.read
    end
    render template: "datastore/viewer/#{@meta.type.tpl}", formats: [:html]
  end


  def edit
    @meta = datastore.get path
    @record = @meta.record
  end


  # Update file name and its desc
  def update
    @meta = datastore.get path
    dirname = File.dirname(path)
    dirname = dirname == '.' ? '' : dirname+'/'
    new_path = dirname+params[:file_name]

    if @meta.name != params[:file_name]
      datastore.mv! path, new_path
    end

    @record = @meta.record
    @record.path = new_path
    @record.name = params[:file_name]
    @record.desc = params[:description]
    @record.save

    redirect_to datastore_edit_path(new_path)
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
    datastore.list(path).each do |f|
      if f.name.start_with?('job-') and f.directory? and datastore.list(f.path).size == 0
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
      @files = datastore.list @dir

      files_tree = @files.collect do |e|
        {
            text: e.name,
            id: e.path,
            children: e.directory?,
            #TODO remove frontend html class
            icon: e.directory? ? 'fa fa-folder' : 'fa fa-file-o'
        }
      end
    end

    render json: files_tree
  end


  def mkdir
    datastore.mkdir! params[:path]
    render json: {success: true}
  end


  def trash
    datastore.trash! params[:path]
    Filerecord.destroy_all path: params[:path], owner_id: current_user.id
    render json: {success: true}
  end


  def mv
    datastore.mv! params[:src], params[:dest]
    render json: {success: true}
  end


  def upload
    if request.post?
      datastore.save! File.join(params[:dir], params[:filename]), params[:file].tempfile
      render json: {success: true}
    else
      gon.dir = params[:dir] || ''
      gon.token = form_authenticity_token
    end
  end


  def download
    path = params[:path]
    f = datastore.get(path)
    if f.is_rdout
      send_data f.read
    else
      send_file datastore.apath(path)
    end

  end

end
