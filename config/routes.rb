Rails.application.routes.draw do
  devise_for :users

  root 'workspaces#show'

  get 'about', to: 'home#about'

  scope :datastore, controller: :datastore, as: :datastore do
    get '/-/(*path)', action:'show'
    patch 'mkdir'
  end


  resource :workspace

  resources :pipelines, :filemetas

  namespace :users do
    resource :profile, :setting
  end

  namespace :admin do
    root 'home#index'
    get 'dashboard', to: 'home#index'
  end
end
