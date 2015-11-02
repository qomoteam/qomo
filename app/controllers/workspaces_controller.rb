class WorkspacesController < ApplicationController
  def show
    @action = flash[:action]
    @pid = flash[:pid]
  end

  def load
    pipeline = Pipeline.find params['id']
    if pipeline.owner.id != current_user.id
      my_pipeline = Pipeline.new title: 'My ' + pipeline.title,
                                 desc: pipeline.desc,
                                 boxes: pipeline.boxes,
                                 connections: pipeline.connections,
                                 params: pipeline.params,
                                 owner_id: current_user.id

      my_pipeline.save
      pipeline = my_pipeline
    end

    flash[:action] = 'load'
    flash[:pid] = pipeline.id
    redirect_to action: 'show'
  end


  def merge
    flash[:action] = 'merge'
    flash[:pid] = params['id']
    redirect_to action: 'show'
  end



end
