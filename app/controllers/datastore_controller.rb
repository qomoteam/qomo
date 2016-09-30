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
      not_found
    end

    if params[:uid] and params[:uid] != current_user.id and !Filerecord.shared?(params[:uid], @meta.path)
      unauthorized
    end

    @page_title = @meta.name unless @meta.name.blank?

    gon.path = path

    if @meta.directory?
      @files = datastore.list(path).sort_by { |f| f.name.downcase }
    else
      params[:offset] ||= 0
      params[:offset] = params[:offset].to_i
      params[:len] = params[:len]&.to_i
      if params[:last]
        @read_result = @meta.read_last(params[:offset], params[:len])
      else
        @read_result = @meta.read(params[:offset], params[:len])
      end
    end

    render template: "datastore/viewer/#{@meta.type.tpl}", formats: [:html]
  end


  def edit
    @meta = datastore.get path
    @record = @meta.record
    render formats: [:html]
  end


  # Update file name and its desc
  def update
    @meta = datastore.get path
    dirname = File.dirname(path)
    dirname = dirname == '.' ? '' : dirname+'/'
    new_path = dirname+params[:file_name]

    @record = @meta.record
    @record.save unless @record.id

    @record.path = new_path
    @record.desc = params[:description]
    @record.save

    if @meta.name != params[:file_name]
      datastore.mv! path, new_path
    end

    redirect_to datastore_edit_path(new_path)
  end


  def share
    record = Filerecord.find_or_create_by(path: path, owner_id: current_user.id)

    record.shared = true
    record.save

    render json: {success: true}
  end


  def unshare
    record = Filerecord.find_or_create_by(path: path, owner_id: current_user.id)
    record.shared = false
    record.save

    render json: {success: true}
  end


  def clear
    datastore.list(path).each do |f|
      if (not f.record.shared) and f.directory? and datastore.list(f.path).size == 0
        f.delete!
        Filerecord.destroy_all path: f.path, owner_id: current_user.id
      end
    end

    redirect_to datastore_path(path)
  end


  def path
    p = params[:path]&.strip || ''
    if p == '/'
      p = ''
    end
    p
  end


  def mkdir
    datastore.mkdir! path
    render json: {success: true}
  end


  def trash
    # Use cannot delete its home dir
    if path == ''
      unauthorized
    end

    Filerecord.destroy_all path: params[:path], owner_id: current_user.id
    Filerecord.destroy_subrecords params[:path], current_user.id

    datastore.trash! path
    render json: {success: true}
  end


  def mv
    src = params[:src].strip
    dest = params[:dest].strip
    datastore.mv! src, dest
    record = Filerecord.find_by path: src, owner_id: current_user.id
    if record
      record.path = File.join(dest, File.basename(src))
      record.save
    end
    render json: {success: true}
  end

  def cp
    datastore.cp params[:src].strip, params[:dest].strip
    render json: {success: true}
  end


  def upload
    @meta = datastore.get(params[:dir] || '')
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
      send_data f.raw_read
    else
      send_file datastore.apath(path)
    end
  end

  def image
    path = params[:path]
    f = datastore.get(path)
    send_data f.raw_read
  end

  def filetree
    files_tree = {}
    if user_signed_in?
      @dir = params['dir'] || ''
      @files = datastore.list @dir

      files_tree = @files.reject { |e| params[:only_dir] and !e.directory? }.collect do |e|
        {
            text: e.name,
            id: e.path,
            children: e.directory?,
            #TODO remove frontend html class
            icon: e.directory? ? 'fa fa-folder' : 'fa fa-file-o',
            type: e.directory? ? 'dir' : 'file'
        }
      end.sort_by { |e| [e[:type], e[:text].downcase] }

      if params[:only_dir] and @dir == ''
        files_tree = [{
            text: '[Root Folder]',
            id: ' ',
            children: files_tree,
            icon: 'fa fa-folder',
            type:'dir',
            state: {opened: true}

        }]
      end
    end

    render json: files_tree
  end


  def fileselector
    render layout: nil
  end

  def dirselector
    render layout: nil
  end

end
