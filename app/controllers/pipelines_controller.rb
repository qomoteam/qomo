class PipelinesController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]

  def index
    @private_pipelines = current_user.try :pipelines
    @pipelines = Pipeline.where shared: true
  end


  def my
    @pipelines = current_user.pipelines
    if params[:inline]
     render 'inline', layout: nil
    else

    end

  end


  def import
    pipeline = Pipeline.find params['id']
    pipeline = pipeline.export_to_user(current_user) if pipeline.owner != current_user

    redirect_to pipeline_path(pipeline)
  end


  def share
    pipeline = Pipeline.find params[:id]
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
    jid = current_user.job_engine.submit @pipeline.merge_params(values), @pipeline.connections

    redirect_to job_path(jid)
  end


  def show
    @pipeline = Pipeline.find params['id']
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
    render layout: nil
  end


  def edit
    @pipeline = Pipeline.find params['id']
  end


  def create
    pipeline = Pipeline.new params.require('pipeline').permit!
    pipeline.owner = current_user
    pipeline.save
    render text: pipeline.id
  end


  def update
    pipeline = Pipeline.find params['id']
    pipeline.update params.require('pipeline').permit!

    respond_to do |format|
      format.html { redirect_to pipeline_path(pipeline) }
      format.json { render json: {success: true} }
    end
  end


  def destroy
    pipeline = Pipeline.find params[:id]
    if pipeline.owner == current_user
      pipeline.destroy!
    end

    redirect_to pipelines_path
  end

end
