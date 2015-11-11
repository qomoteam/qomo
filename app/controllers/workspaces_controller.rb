class WorkspacesController < ApplicationController
  def show
    @action = flash[:action]
    @pid = flash[:pid]
  end

  def load
    pipeline = Pipeline.find params['id']
    pipeline = pipeline.owner.id != current_user.id ? pipeline.export_to_user(current_user) : pipeline

    flash[:action] = 'load'
    flash[:pid] = pipeline.id
    redirect_to action: 'show'
  end


  def merge
    flash[:action] = 'merge'
    flash[:pid] = params['id']
    redirect_to action: 'show'
  end


  def run
    current_user.job_engine.submit JSON.parse(params[:boxes]), JSON.parse(params[:connections])
    render json: {success: true}
  end


end
