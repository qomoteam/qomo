class Admin::CategoriesController < Admin::ApplicationController

  def index
    @category = Category.new
    @categories = Category.all
  end

  def show
  end

  def create
    @category = Category.create params.require('category').permit!
    redirect_to action: 'index'
  end

end
