Rails.application.routes.draw do
  
  namespace :admin do
    resources :balance_adjustments
    resources :platforms
    resources :withdrawals
    resources :assets
  end
  
  resources :orders
  resources :withdrawals
  resources :deposits
  resources :balance_adjustments
  resources :authorization_codes

  get '/login'     => 'authorization_codes#new'
  delete '/logout' => 'access_tokens#destroy'
  
  # get '/balances' => 'pages#balances'
  root to: 'pages#welcome'
  
  # Vue app
  get '/:page' => 'pages#app'
end
