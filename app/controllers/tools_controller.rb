class ToolsController < ApplicationController
  def index
  end

  def new
    @tool = Tool.new
  end

end
