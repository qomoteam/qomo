class PipelinesController < ApplicationController

  before_action :authenticate_user!, except: [:index, :search, :show]

  def index
    @categories = Category.roots
    if params[:category_id]
      @current = Category.find_by_slug params[:category_id]
      @pipelines = @current.descendant_shared_pipelines
      @page_title = "Pipelines: #{@current.name}"
    else
      @pipelines = Pipeline.shared
    end

    @pipelines = @pipelines.page params[:pp]
  end


  def my
    @pipelines = current_user.pipelines
    render 'inline', layout: nil if params[:inline]
  end


  def search
    @categories = Category.roots
    q = params[:q]
    pipeline = Pipeline.find_by_accession_label q
    return redirect_to user_pipeline_path(pipeline.owner.username, pipeline.slug) if pipeline&.shared
    @pipelines = Pipeline.shared.where('lower(title) like ?', "%#{q.downcase}%").page params[:pp]
    render :index
  end


  def import
    pipeline = Pipeline.find params['id']
    pipeline = pipeline.export_to_user(current_user) if pipeline.owner != current_user

    redirect_to pipeline_path(pipeline)
  end


  def toogle_shared
    pipeline = Pipeline.find params[:id]
    authorize! :manage, pipeline

    pipeline.update shared: params[:shared].to_bool

    if pipeline.shared
      pipeline.boxes.values.each do |e|
        tool = Tool.find e['tool_id']
        tool.inputs.each do |input|
          path = e['values'][input['name']]
          unless path.blank?
            record = Filerecord.find_or_create_by(path: path, owner_id: current_user.id)
            record.shared = true
            record.save
          end
        end
      end
    end

    render json: {success: true}
  end


  def run
    @pipeline = Pipeline.find params[:id]
    if @pipeline.owner != current_user
      @pipeline = @pipeline.export_to_user(current_user)
    end
    values = JSON.parse params[:pipelinevalues]

    job_name = params[:job_name].blank? ? "#{@pipeline.title} #{Time.now.hour}#{Time.now.min}#{Time.now.sec}" : params[:job_name]
    result = current_user.job_engine.submit job_name, @pipeline.merge_params(values), @pipeline.connections

    if result[:success]
      redirect_to job_path(result[:job_id])
    else
      flash[:notice] = 'Error occured when submit pipeline'
      redirect_to pipeline_path(@pipeline)
    end
  end


  def show
    if params[:user_id]
      user = User.find_by_username params[:user_id]
      not_found unless user
      @pipeline = Pipeline.find_by_owner_id_and_slug user.id, params['id']
    else
      @pipeline = Pipeline.find_by_accession_label params['id']
      @pipeline = Pipeline.find params['id'] unless @pipeline&.shared
    end

    not_found unless @pipeline
    authorize! :read, @pipeline

    set_page_title "Pipeline: #{@pipeline.title}"

    respond_to do |format|
      format.html
      format.json do
        if @pipeline.owner != current_user
          @pipeline.polish_export_params!
        end
        if params[:simple]
          render json: {accession: @pipeline.accession, title: @pipeline.title, updated_at: @pipeline.updated_at.to_s(:db)}
        else
          render json: @pipeline
        end
      end
    end
  end


  def export
    @pipeline = Pipeline.find params['id']
    send_data @pipeline.to_json(except: [:owner_id, :shared]),
              filename: "#{@pipeline.accession}.qomo-pipeline"
  end


  def new
    @pipeline = Pipeline.new
    @categories = Category.all
    render layout: nil
  end


  def edit
    @pipeline = Pipeline.find params['id']
    authorize! :update, @pipeline
    pp @pipeline.persisted?
    @categories = Category.all
  end


  def create
    wrapping_json_param
    pipeline = Pipeline.new params.require('pipeline').permit!
    pipeline.owner = current_user
    pipeline.save
    render json: {id: pipeline.id, title: pipeline.title, success: true}
  end


  def update
    wrapping_json_param
    pipeline = Pipeline.find params['id']
    not_found unless pipeline

    authorize! :update, @pipeline
    pipeline.slug = nil
    pipeline.update params.require('pipeline').permit!

    respond_to do |format|
      format.html { redirect_to user_pipeline_path(pipeline.owner.username, pipeline.slug) }
      format.json { render json: {success: true} }
    end
  end


  def destroy
    pipeline = Pipeline.find params[:id]
    unauthorized if current_user != @pipeline.owner

    pipeline.destroy!

    redirect_to pipelines_path
  end


  def toogle_featured
    unauthorized unless current_user.has_role? :admin

    pipeline = Pipeline.find(params[:id])
    if pipeline.featured == 0
      pipeline.featured = 1
    else
      pipeline.featured = 0
    end

    pipeline.save

    redirect_to pipeline_path(pipeline)
  end


  def wrapping_json_param
    # In RAILS 5 we have to do this manully
    params[:pipeline][:boxes] = JSON.parse(params[:pipeline][:boxes]) if params[:pipeline][:boxes]
    params[:pipeline][:connections] = JSON.parse(params[:pipeline][:connections]) if params[:pipeline][:connections]
    params[:pipeline][:params] = JSON.parse(params[:pipeline][:params])if params[:pipeline][:params]
  end


  def bookmark
    pipeline = Pipeline.find params[:id]
    not_found unless pipeline
    unauthorized unless pipeline.shared
    unauthorized if current_user.is_guest?

    if current_user.liked? pipeline
      current_user.unlike pipeline
    else
      current_user.likes pipeline
    end

    redirect_back fallback_location: user_pipeline_path(pipeline.owner.username, pipeline.slug)
  end


  def bookmarks
    set_page_title 'Pipeline Bookmarks'
    @pipelines = current_user.get_voted(Pipeline).page params[:pp]
  end

end
