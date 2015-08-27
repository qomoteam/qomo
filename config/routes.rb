Rails.application.routes.draw do
  root 'workspaces#show'

  get 'about', to: 'home#about'

  resource :workspace
  resources :pipelines
end
