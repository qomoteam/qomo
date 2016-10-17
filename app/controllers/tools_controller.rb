class ToolsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :search, :show]

  def index
    @categories = Category.roots
    if params[:category_id]
      @current = Category.find_by_slug params[:category_id]
      @tools = @current.descendant_active_tools
    else
      @tools = Tool.active
    end

    @tools = @tools.page params[:page]
  end

  def my
    @tools = current_user.tools
  end

  def search
    @categories = Category.roots
    @tools = Tool.where(status: 1).where('lower(name) like ?', "%#{params[:q].downcase}%")
    render :index
  end


  def new
    @tool = Tool.new
    @categories = Category.all
    render template: 'tools/edit'
  end


  def create
    unauthorized if current_user.has_role? :guest

    @tool = Tool.new params.require(:tool).permit!
    @tool.owner = current_user

    if @current_user.has_role? :admin
      @tool.active!
    end

    @tool.save
    @tool.copy_upload!
    redirect_to edit_tool_path(@tool)
  end


  def edit
    @tool = Tool.find params['id']
    unauthorized if current_user != @tool.owner

    @categories = Category.all
  end


  def update
    tool = Tool.find params['id']
    unauthorized if current_user != tool.owner

    tool.slug = nil
    tool.update params.require(:tool).permit!
    tool.copy_upload!
    redirect_to edit_tool_path(tool)
  end


  def destroy
    tool = Tool.find params['id']
    unauthorized if current_user != @tool.owner

    tool.destroy!
    redirect_to action: 'index', status: :see_other
  end


  def delete
    Tool.delete params['ids']
    redirect_to action: 'index', status: :see_other
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
    if params[:user_id]
      user = User.find_by_username params[:user_id]
      not_found unless user
      @tool = Tool.find_by_owner_id_and_slug user.id, params['id']
    else
      @tool = Tool.find params['id']
    end

    not_found unless @tool
    @page_title = @tool.name

    unauthorized unless @tool.active? or @tool.owner == current_user
  end


  def help
    @tool = Tool.find params['id']
    render layout: nil
  end


  def asset_mkexe
    tool = Tool.find params['id']
    unauthorized if current_user != tool.owner

    path = File.join(tool.dirpath, params[:path])
    if File.executable? path
      File.chmod(0655, path)
    else
      File.chmod(0755, path)
    end

    render json: {success: true}
  end

  def asset_download
    if params[:release_id]
      release = Release.find params[:release_id]
      not_found unless release
      tool = release.tool
    else
      tool = Tool.find params['id']
    end

    unauthorized if current_user != tool.owner

    if release
      prefix = release.download_path
    else
      prefix = tool.dirpath
    end

    path = File.join(prefix, params[:path])
    send_file path
  end

  def asset_delete
    if params[:release_id]
      release = Release.find params[:release_id]
      not_found unless release
      tool = release.tool
    else
      tool = Tool.find params['id']
    end

    unauthorized if current_user != tool.owner

    if release
      prefix = release.download_path
    else
      prefix = tool.dirpath
    end

    File.delete File.join(prefix, params[:path])
    render json: {success: true}
  end

  def toogle_featured
    unauthorized unless current_user.has_role? :admin

    tool = Tool.find(params[:id])
    if tool.featured == 0
      tool.featured = 1
    else
      tool.featured = 0
    end

    tool.save

    redirect_to tool_path(tool)
  end

  # Return tags in Select2 JSON format
  def tags
    q = params[:q]
    tags = ActsAsTaggableOn::Tag.where('name like ?', "#{q}%")
    render json: tags.collect {|t| {id: t.name, text: t.name}}
  end


  def run
    tool = Tool.find(params[:id])

    not_found unless tool
    unauthorized unless tool.runnable

    job_name = "#{tool.name} #{Time.now.hour}#{Time.now.min}#{Time.now.sec}"

    bid = SecureRandom.uuid
    boxes = {}
    boxes[bid] = {
        id: bid,
        tool_id: tool.id,
        values: Hash[*tool.params.collect {|p| [p['name'], params[p['name']]]}.flatten]
    }.stringify_keys

    result = current_user.job_engine.submit job_name, boxes, []

    if result[:success]
      redirect_to job_path(result[:job_id])
    else
      flash[:notice] = 'Error occured when submit pipeline'
      redirect_to user_tool_path(tool.owner.username, tool.slug)
    end
  end

end
