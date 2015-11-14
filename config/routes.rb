Rails.application.routes.draw do
  devise_for :users

  root 'workspaces#show'

  get 'about', to: 'home#about'
  get 'agreement', to: 'home#agreement'
  get 'tutorial', to: 'home#tutorial'

  scope :datastore, controller: :datastore, as: :datastore do
    get '/-/(*path)', action: 'show', constraints: { :path => /.*/ }
    put '/clear/-/(*path)', action: 'clear', as: :clear, constraints: { :path => /.*/ }
    patch :mkdir
    patch :mv
    delete :trash

    patch '/share/-/(*path)', action: 'share', as: :share, constraints: {:path => /.*/ }
    patch '/unshare/-/(*path)', action: 'unshare', as: :unshare, constraints: {:path => /.*/ }

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
      get :import
      patch :share
      patch :unshare
      get :export
      post :run
    end
  end


  resources :jobs do
    collection do
      get :summary
      put :clear
    end

  end


  resources :filemetas


  namespace :users do
    resource :profile, :setting
  end

  get 'scholar/:username', to: 'scholar#show', as: :scholar

  namespace :admin do
    root 'home#index'
    get 'dashboard', to: 'home#index'
    resources :categories, :users
  end

end
