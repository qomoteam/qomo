module ApplicationHelper

  def title_tag
    if @page_title
      title = @page_title
    else
      title = params[:controller].split('/')
    end

    if title.kind_of? Array
      title = (title.map {|e| e.humanize}).join ' » '
    end

    title = "Qomo | #{title}"

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

end
