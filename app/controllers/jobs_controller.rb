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
    @job = Job.find params[:id]
    not_found unless @job
    authorize! :read, @job
    set_page_title @job.name
    gon.job_id = @job.id
  end


  def destroy
    job = Job.find params[:id]
    job.destroy!
    redirect_to jobs_path, status: :see_other
  end


  def clear
    Job.all.each do |j|
      if j.status == 'failed' or j.status == 'success'
        j.destroy
      end
    end
    redirect_to jobs_path
  end

end
