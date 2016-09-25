module DatastoreHelper

  def parent_dir(path)
    path.split('/')[0..-2].join('/')
  end


  def breadcrumb(path)
    tmp = nil
    path.split('/')[0..-2].map do |e|
      p = tmp ? File.join(tmp, e) : e
      tmp = p
      [p, e]
    end
  end


  def own?(filemeta)
    filemeta.owner_id == current_user.id
  end


  def tsv_header(row)
    row[0]&.start_with?('#') ? 'header' : ''
  end

  def viewer_path(file)
    if file.type.reader
      datastore_path(file.path, uid: params[:uid])
    else
      datastore_download_path(file.path, uid: params[:uid])
    end
  end

end
