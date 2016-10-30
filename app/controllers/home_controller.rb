class HomeController < ApplicationController

  def index
    @pipelines = Pipeline.featured.limit(5)
    @tools = Tool.featured.limit(16)
    @count = {}
    @count[:tools] = Tool.shared.count
    @count[:pipelines] = Pipeline.shared.count
  end

  def about
  end

  def agreement
  end

  def tutorial
  end


  def publication_search
    render json: PubmedApi.find(params[:pmid])[0] || {}
  end

end
