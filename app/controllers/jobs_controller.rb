class JobsController < ApplicationController

  def index
    @jobs = current_user.jobs created_at: :desc
  end


  def summary
    @jobs = current_user.jobs.order(created_at: :desc).limit(5)
    render layout: nil
  end


  def show
    @job = Job.find params[:id]
  end


  def destroy
    Job.delete params[:id]
    redirect_to action: :index
  end

end
