Rails.application.routes.draw do
  get 'trades/index'
  namespace :admin do
    resources :brandings
    resources :balance_adjustments
    resources :platforms
    resources :withdrawals
    resources :assets
  end

  resources :users, only:[:update, :edit]
  resources :pictures
  resources :orders
  resources :withdrawals
  resources :deposits
  resources :balance_adjustments
  resources :cached_balances
  resources :authorization_codes
  resources :pages
  resources :airdrops
  
  resources :trade do
    # Render json data for amcharts.js stock graph
    get 'chart', on: :collection
  end
  resources :assets do
    # serves erc20 .sol file
    get 'contract', on: :collection
  end

  get '/login'     => 'authorization_codes#new'
  delete '/logout' => 'access_tokens#destroy'

  get '/me'      => 'users#show'
  get '/me/edit' => 'users#edit'

  root to: 'pages#welcome'
end
