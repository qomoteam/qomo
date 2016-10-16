module LinksHelper

  def tool_link(tool)
    link_to tool.name, user_tool_path(tool.owner.username, tool.name)
  end

  def category_tools_link(category, show_count=false)
    text = category.name
    if show_count
      text = "#{text} (#{category.descendant_active_tools.count})"
    end
    link_to text, category_tools_path(category.slug)
  end

  def category_pipelines_link(category, show_count=false)
    text = category.name
    if show_count
      text = "#{text} (#{category.descendant_shared_pipelines.count})"
    end
    link_to text, category_pipelines_path(category.slug)
  end

end
