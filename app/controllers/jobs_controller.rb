class JobsController < ApplicationController

  before_action :authenticate_user!

  def index
    @jobs = current_user.jobs(created_at: :desc)
  end


  def summary
    @jobs = current_user.jobs.order(created_at: :desc).limit(5)
    render layout: nil
  end


  def show
    r = Job.where id: params[:id], user_id: current_user.id
    if r.length != 1
      raise ActiveRecord::RecordNotFound
    else
      @job = r[0]
    end
  end


  def destroy
    Job.delete params[:id]
    redirect_to action: :index
  end


  def clear
    Job.failed.each do |j|
      j.destroy
      current_user.datastore.delete! "job-#{j.id}"
    end
    redirect_to jobs_path
  end

end
