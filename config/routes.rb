Rails.application.routes.draw do
  get 'jobs/index'

  get 'jobs/show'

  devise_for :users

  root 'workspaces#show'

  get 'about', to: 'home#about'

  scope :datastore, controller: :datastore, as: :datastore do
    get '/-/(*path)', action: 'show', constraints: { :path => /.*/ }
    patch 'mkdir'
    patch 'mv'
    delete 'trash'

    get :filetree

    match 'upload/-/(*dir)', action: 'upload', as: 'upload', constraints: { :path => /.*/ }, via: [:get, :post]
    get 'download/-/(*path)', action: 'download', as: 'download', constraints: { :path => /.*/ }
  end


  resource :workspace do
    get 'load/:id', action: :load, as: :load
    get 'merge/:id', action: :merge, as: :merge
    post :run
  end

  resources :tools do
    collection do
      post :boxes
    end
    member do
      get :help
    end
  end

  resources :pipelines do
    collection do
      get :my
    end
    member do
      get :export
    end
  end

  resources :jobs

  resources :filemetas

  namespace :users do
    resource :profile, :setting
  end

  namespace :admin do
    root 'home#index'
    get 'dashboard', to: 'home#index'
    resources :categories
  end

end
