Rails.application.routes.draw do

  mount ActionCable.server => '/cable'

  mount RuCaptcha::Engine => '/captcha'

  post '/rate' => 'rater#create', :as => 'rate'

  devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
  }

  devise_scope :user do
    post 'users/guest_signin', to: 'users/sessions#guest_signin', as: 'guest_signin'
  end

  root 'home#index'

  namespace :explore do
    get 'pipelines'
    get 'tools'
    resources :categories do
      get :pipelines, to: '/explore#pipelines'
    end
  end

  get 'publication_search', to: 'home#publication_search'

  get 'about', to: 'home#about'
  get 'agreement', to: 'home#agreement'
  get 'tutorial', to: 'home#tutorial'

  get 'library', to: 'library#index'
  get 'library/filetree', to: 'library#filetree'

  scope :datastore, controller: :datastore, as: :datastore do
    get '/-/(*path)', action: 'show', constraints: { :path => /.*/ }
    put '/clear/-/(*path)', action: 'clear', as: :clear, constraints: { :path => /.*/ }

    post :search
    patch :mkdir
    patch :cp
    patch :mv
    delete :trash

    get '/edit/-/(*path)', action: 'edit', as: :edit, constraints: { :path => /.*/ }
    patch '/-/(*path)', action: 'update', as: :update, constraints: { :path => /.*/ }

    patch '/share/-/(*path)', action: 'share', as: :share, constraints: {:path => /.*/ }
    patch '/unshare/-/(*path)', action: 'unshare', as: :unshare, constraints: {:path => /.*/ }

    get :filetree

    get :fileselector
    get :dirselector

    match 'upload/-/(*dir)', action: 'upload', as: 'upload', constraints: { :path => /.*/ }, via: [:get, :post]
    get 'download/-/(*path)', action: 'download', as: 'download', constraints: { :path => /.*/ }
    get 'image/-/(*path)', action: 'image', as: 'image', constraints: { :path => /.*/ }
  end


  resource :workspace do
    get 'load/:id', action: :load, as: :load
    get 'merge/:id', action: :merge, as: :merge

    post :run
  end

  resources :categories do
    resources :tools, :pipelines
  end

  resources :tools do
    resources :releases do
      member do
        get :download
      end
    end

    collection do
      get :search
      post :boxes
      get :tags
      get :my
      get :bookmarks
    end

    member do
      get :help
      post :asset_mkexe
      get :asset_download
      delete :asset_delete
      patch :toogle_featured
      post :run
      get :bookmark
      get :request_audit
    end
  end


  resources :pipelines do
    collection do
      get :search
      get :my
      get :bookmarks
    end
    member do
      get :import
      patch :share
      patch :unshare
      patch :toogle_featured
      get :export
      post :run
      post :star
      get :bookmark
    end
  end


  resources :jobs do
    collection do
      get :summary
      put :clear
    end
  end


  resources :filemetas


  resources :users do
    collection do
      resource :profile, :setting
    end
    resources :pipelines

    resources :tools do
      resources :releases
    end
  end


  get 'scholar/:username', to: 'scholar#show', as: :scholar


  namespace :admin do
    root to: 'home#index', as: :root
    get 'dashboard', to: 'home#index'
    resources :categories

    resources :tools do
      member do
        get :approve_audit
      end
      collection do
        get :audit
      end
    end

    resources :users do
      collection do
        delete :destroy_expired
      end
    end
  end

end
