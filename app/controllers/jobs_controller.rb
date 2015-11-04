class JobsController < ApplicationController

  def index
    @jobs = Job.order created_at: :desc
  end


  def summary
    @jobs = Job.order(created_at: :desc).limit(5)
    render layout: nil
  end


  def show
    @job = Job.find params[:id]
  end
end
