class ToolsController < ApplicationController

  def index
    @tools = current_user&.tools

    @categories = Category.all

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
    @tool.copy_upload!
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
    tool.copy_upload!
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


  def asset_mkexe
    tool = Tool.find params['id']
    path = File.join(tool.dirpath, params[:path])
    if File.executable? path
      File.chmod(0655, path)
    else
      File.chmod(0755, path)
    end

    render json: {success: true}
  end

  def asset_download
    tool = Tool.find params['id']
    path = File.join(tool.dirpath, params[:path])
    send_file path
  end

  def asset_delete
    tool = Tool.find params['id']
    path = File.join(tool.dirpath, params[:path])
    File.delete path
    render json: {success: true}
  end

end
