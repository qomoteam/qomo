class JobsController < ApplicationController
  def index
    @jobs = Job.order created_at: :desc
  end

  def show
    @job = Job.find params[:id]
  end
end
