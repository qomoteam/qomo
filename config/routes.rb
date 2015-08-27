Rails.application.routes.draw do
  root 'workspaces#show'

  get 'about', to: 'home#about'

  resource :workspace
  resources :pipelines

  namespace :admin do
    root 'home#index'
    get 'dashboard', to: 'home#index'
  end
end
