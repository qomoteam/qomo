class ExploreController < ApplicationController
  def index
    if params[:category_id]
      @pipelines = Pipeline.where shared: true, category_id: params[:category_id]
    else
      @pipelines = Pipeline.where shared: true
    end
    
    @categories = Category.all
  end

  def pipelines
    if params[:category_id]
      @pipelines = Pipeline.where shared: true, category_id: params[:category_id]
    else
      @pipelines = Pipeline.where shared: true
    end

  end

  def tools
    @categories = Category.all
  end


end
