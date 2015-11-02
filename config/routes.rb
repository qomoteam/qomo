Rails.application.routes.draw do
  devise_for :users

  root 'workspaces#show'

  get 'about', to: 'home#about'

  scope :datastore, controller: :datastore, as: :datastore do
    get '/-/(*path)', action: 'show', constraints: { :path => /.*/ }
    patch 'mkdir'
    patch 'mv'
    delete 'trash'

    match 'upload/-/(*dir)', action: 'upload', as: 'upload', constraints: { :path => /.*/ }, via: [:get, :post]
    get 'download/-/(*path)', action: 'download', as: 'download', constraints: { :path => /.*/ }
  end


  resource :workspace do
    get 'load/:id', to: :load, as: :load
    get 'merge/:id', to: :merge, as: :merge
  end

  resources :tools do
    collection do
      post :boxes
    end
  end
  resources :pipelines do
    collection do
      get :my
    end
  end

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
