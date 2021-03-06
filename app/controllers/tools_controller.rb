class ToolsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :search, :show]

  def index
    authorize! :index, Tool

    @categories = Category.roots
    if params[:category_id]
      @current = Category.find_by_slug params[:category_id]
      @tools = @current.descendant_shared_tools
      @page_title = "Tools: #{@current.name}"
    else
      @tools = Tool.shared
    end

    @tools = @tools.page params[:tp]
  end

  def my
    authorize! :my, Tool
    @tools = current_user.tools
  end

  def search
    @categories = Category.roots
    q = params[:q]
    tool = Tool.find_by_accession_label q

    return redirect_to user_tool_path(tool.owner.username, tool.slug) if tool&.shared

    @tools = Tool.shared.where('lower(name) like ?', "%#{q.downcase}%").page params[:tp]
    render :index
  end


  def new
    @tool = Tool.new
    @categories = Category.all
    render template: 'tools/edit'
  end


  def create
    authorize! :create, Tool

    tool = Tool.new params.require(:tool).permit!
    tool.owner = current_user

    if @current_user.has_role? :admin
      tool.shared = true
    end

    tool.save
    tool.copy_upload!
    redirect_to user_tool_path(tool.owner.username, tool.slug)
  end


  def edit
    @tool = Tool.find params['id']
    authorize! :edit, @tool
    @categories = Category.all
  end

  def edit_runtimeconf
    @tool = Tool.find params['id']
    authorize! :edit, @tool
  end


  def update
    tool = Tool.find params['id']
    authorize! :update, tool

    tool.slug = nil
    tool.update params.require(:tool).permit!
    tool.copy_upload!

    redirect_back fallback_location: user_tool_path(tool.owner.username, tool.slug)
  end


  def destroy
    tool = Tool.find params['id']
    authorize! :destroy, tool

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
      @tool = Tool.find_by_accession_label params['id']
      @tool = Tool.find params['id'] unless @tool&.shared
    end

    not_found unless @tool
    @page_title = @tool.name

    authorize! :show, @tool

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


  def bookmark
    tool = Tool.find params[:id]
    not_found unless tool
    unauthorized unless tool.shared
    unauthorized if current_user.is_guest?

    if current_user.liked? tool
      current_user.unlike tool
    else
      current_user.likes tool
    end

    redirect_back fallback_location: user_tool_path(tool.owner.username, tool.slug)
  end


  def bookmarks
    set_page_title 'Tool Bookmarks'
    @tools = current_user.get_voted(Tool).page params[:tp]
  end


  def request_audit
    tool = Tool.find params[:id]
    not_found unless tool
    unauthorized if tool.shared or current_user.is_guest?
    tool.audit = true
    tool.save
    redirect_back fallback_location: user_tool_path(tool.owner.username, tool.slug)
  end

end
