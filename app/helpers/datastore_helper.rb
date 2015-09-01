module DatastoreHelper

  def parent_dir(path)
    path.split('/')[0..-2]

  end

end
