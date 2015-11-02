class PipelinesController < ApplicationController

  def index
  end

  def my
    @pipelines = Pipeline.belongs_to_user current_user
    if params[:inline]
     render 'inline', layout: nil
    else

    end

  end


  def show
    @pipeline = Pipeline.find params['id']
    respond_to do |format|
      format.html
      format.json { render json: @pipeline }
    end
  end


  def new
    @pipeline = Pipeline.new
    render 'edit', layout: nil
  end


  def edit
    @pipeline = Pipeline.find params['id']
    @pipeline.contributors = current_user.full_name
    render 'edit', layout: nil
  end


  def create
    pipeline = Pipeline.new params.require('pipeline').permit!
    pipeline.owner = current_user
    pipeline.save
    render text: pipeline.id
  end


  def update
    pipeline = Pipeline.find params['id']
    pipeline.update(params.require('pipeline').permit!)

    if pipeline.public
      polish_params pipeline
      pipeline.save
    end

    respond_to do |format|
      format.html {redirect_to pipeline_path(pipeline)}
      format.json { render json: {success: true} }
    end
  end


  def destroy
    Pipeline.delete params['id']
    redirect_to action: 'my'
  end


  def mark_public
    pipeline = Pipeline.find params['id']
    pipeline.public = (params['mark'] == 'true')
    polish_params pipeline
    pipeline.save
    render json: {success: true}
  end


  protected

  def polish_params(pipeline)
    jb = JSON.parse(pipeline.boxes)
    jb.each do |k, v|
      tool = Tool.find v['tid']
      tool.inputs.each do |tp|
        v['values'].each do |pk, pv|
          if tp['name'] == pk and (not pv.blank?) and (not pv.start_with? '@')
            jb[k]['values'][pk] = "@#{current_user.username}:#{pv}"
          end
        end
      end
    end
    pipeline.boxes = JSON.dump jb
    pipeline.save
  end
end
