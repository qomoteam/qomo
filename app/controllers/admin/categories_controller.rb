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


  def edit
    @category = Category.find params[:id]
  end


  def update
    category = Category.find params['id']
    category.slug = nil
    category.update params.require('category').permit!
    redirect_to admin_categories_path
  end


  def destroy
    category = Category.find params['id']
    category.delete!
    redirect_to admin_categories_path
  end

end
