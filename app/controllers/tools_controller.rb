class ToolsController < ApplicationController
  def index
    @tools = current_user.tools
    @all_tools = Tool.all.active
  end


  def new
    @tool = Tool.new
    @categories = Category.all
  end


  def create
    @tool = Tool.new params.require(:tool).permit!
    @tool.owner = current_user

    if @current_user.has_role? :admin
      @tool.active!
    end

    @tool.save
    redirect_to action: 'edit', id: @tool.id
  end


  def edit
    @tool = Tool.find params['id']
    @categories = Category.all
    render 'new'
  end


  def update
    tool = Tool.find params['id']
    tool.update params.require(:tool).permit!
    redirect_to action: 'edit', id: tool.id
  end


  def destroy
    Tool.delete params['id']
    redirect_to action: 'index'
  end


  def delete
    Tool.delete params['ids']
    redirect_to action: 'index'
  end


  def boxes
    @boxes = params['boxes'].map do |e|
      bid = e['id'] || SecureRandom.uuid
      tool = Tool.find e['tool_id']
      {id: bid, tool: tool}
    end

    render 'boxes', layout: nil
  end

  
  def show
    @tool = Tool.find params['id']
  end


  def help
    @tool = Tool.find params['id']
    render layout: nil
  end


end
