class HomeController < ApplicationController
  def index
    @pipelines = Pipeline.where(shared: true).order(:cached_votes_score => :desc).limit(6)
    @tools = Tool.active.limit(20)
  end

  def about
  end

  def agreement
  end

  def tutorial
  end

end
