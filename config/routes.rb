Rails.application.routes.draw do
  resources :pictures
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
  resources :pages
  resources :airdrops

  resources :assets do
    get 'contract', on: :collection
  end

  get '/login'     => 'authorization_codes#new'
  delete '/logout' => 'access_tokens#destroy'
  
  root to: 'pages#welcome'
  
  # Vue app
  get '*path' => 'pages#app', constraints: lambda { |req|
    # Workaround for open rails issue
    # https://github.com/rails/rails/issues/31228#issuecomment-352900551
    req.path.exclude? 'rails/active_storage'
  }
end
