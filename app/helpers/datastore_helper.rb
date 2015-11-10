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


  def shared_tag(shared)
    if shared
      content_tag 'aui-toggle', nil, {class: 'shared-toggle', label: 'Shared', checked: 'on'}
    else
      content_tag 'aui-toggle', nil, {class: 'shared-toggle', label: 'Shared'}
    end
  end

end
