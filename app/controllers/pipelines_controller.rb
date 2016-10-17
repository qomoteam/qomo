class PipelinesController < ApplicationController

  before_action :authenticate_user!, except: [:index, :search, :show]

  def index
    @categories = Category.roots
    if params[:category_id]
      @current = Category.find_by_slug params[:category_id]
      @pipelines = @current.descendant_shared_pipelines
    else
      @pipelines = Pipeline.shared
    end

    @pipelines = @pipelines.page params[:page]
  end


  def my
    @pipelines = current_user.pipelines
    if params[:inline]
      render 'inline', layout: nil
      return
    end
  end


  def search
    @categories = Category.roots
    @pipelines = Pipeline.shared.where('lower(title) like ?', "%#{params[:q].downcase}%")
    render :index
  end


  def import
    pipeline = Pipeline.find params['id']
    pipeline = pipeline.export_to_user(current_user) if pipeline.owner != current_user

    redirect_to pipeline_path(pipeline)
  end


  def share
    pipeline = Pipeline.find params[:id]
    unauthorized if current_user != pipeline.owner

    pipeline.shared = true
    pipeline.save
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
    render json: {success: true}
  end


  def unshare
    pipeline = Pipeline.find params[:id]
    unauthorized if current_user != pipeline.owner

    pipeline.shared = false
    pipeline.save
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
      @pipeline = Pipeline.find params['id']
    end

    not_found unless @pipeline
    unauthorized unless @pipeline.shared or @pipeline.owner == current_user

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
    unauthorized if current_user != @pipeline.owner
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

    unauthorized if current_user != pipeline.owner
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


  def star
    pipeline = Pipeline.find(params[:id])
    user = current_user
    if user.voted_for? pipeline
      pipeline.unliked_by user
    else
      pipeline.liked_by user
    end
    render json: {success: true}
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

end
