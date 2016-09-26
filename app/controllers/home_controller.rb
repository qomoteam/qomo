class HomeController < ApplicationController

  def index
    @pipelines = Pipeline.where(shared: true).order(:cached_votes_score => :desc).limit(5)
    @tools = Tool.active.limit(16)
    @count = {}
    @count[:tools] = Tool.active.count
    @count[:pipelines] = Pipeline.where(shared: true).count
  end

  def about
  end

  def agreement
  end

  def tutorial
  end

end
