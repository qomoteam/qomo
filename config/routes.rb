Rails.application.routes.draw do
  devise_for :users

  root 'workspaces#show'

  get 'about', to: 'home#about'

  resource :workspace

  resources :pipelines

  namespace :users do
    resource :profile
  end

  namespace :admin do
    root 'home#index'
    get 'dashboard', to: 'home#index'
  end
end
