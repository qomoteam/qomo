class ExploreController < ApplicationController

  def pipelines
    if params[:category_id]
      @pipelines = Pipeline.where shared: true, category_id: params[:category_id]
    else
      @pipelines = Pipeline.where shared: true
    end

    @count = Pipeline.shared_count

  end

  def tools
    @categories = Category.all
    @count = Tool.active_count
  end

end
