class ToolsController < ApplicationController
  def index
  end

  def new
    @tool = Tool.new
    @categories = Category.all
  end

end
