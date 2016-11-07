module ApplicationHelper

  include LinksHelper

  def title_tag
    if @page_title
      title = @page_title
    else
      title = params[:controller].split('/')
    end

    if title.kind_of? Array
      title = (title.map { |e| e.humanize }).join ' » '
    end

    content_tag :title, title
  end


  def page_title(title)
    @page_title = title
  end

  def active_class(controller, action=nil, cls='active')
    params[:controller] == controller and params[:action] == (action || params[:action]) ? cls : ''
  end


  def revision_tag
    Config.revision
  end


  def empty_row(collection, colspan)
    return if collection and collection.length > 0
    content_tag :tr, content_tag(:td, 'Empty', colspan: colspan), class: 'empty'
  end


  def ptime(ts, timezone)
    ts.nil? ? '' : ts.in_time_zone(timezone).strftime('%F %T')
  end

  def status_label(status)
    status ||= :unknown
    clz = ''
    case status
      when 'success'
        clz = 'aui-lozenge aui-lozenge-success'
      when 'failed'
        clz = 'aui-lozenge aui-lozenge-error'
      when 'running'
        clz = 'aui-lozenge aui-lozenge-complete'
      else
        clz = 'aui-lozenge'
    end
    content_tag :span, status.upcase, class: clz, style: 'width: 66px'
  end


  def shared_tag(shared)
    opts = {class: 'shared-toggle', label: 'Shared'}
    opts[:checked] = 'on' if shared
    content_tag 'aui-toggle', nil, opts
  end

  def aui_toggle(k, v)
    opts = {name: k, label: k}
    opts[:checked] = 'on' if v
    content_tag 'aui-toggle', nil, opts
  end


  def user_tag(user)
    display = user.full_name.blank? ? user.username : user.full_name
    content_tag :a, display, href: scholar_path(user.username)
  end


  def contributors_tag(str, link=true)
    str.split(',').map do |c|
      c = c.strip
      if c.start_with? '@'
        c = c[1..-1]
        user = User.find_by_username c
        if user
          if link
            user_tag user
          else
            user.full_name.blank? ? user.username : user.full_name
          end
        else
          c
        end
      else
        c
      end
    end.join ', '
  end


  def all_categories
    Category.all
  end

  def viewer_path(file)
    uid = nil
    if not user_signed_in? or current_user.id != file.owner_id
      uid = file.owner_id
    end
    if file.directory? or file.type.reader
      datastore_path(file.path, uid: uid)
    else
      datastore_download_path(file.path, uid: uid)
    end
  end


  def hide_style(b)
    'display: none' unless b
  end


  def not_guest_user?
    user_signed_in? and (not current_user.is_guest?)
  end


end
