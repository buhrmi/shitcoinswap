Rails.application.routes.draw do

  resources :authorization_codes, only:[:new, :create]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :admin do
    resources :balance_adjustments
    resources :platforms
    resources :withdrawals
    resources :assets
  end

  resources :orders
  resources :withdrawals
  resources :deposits

  get '/login'     => 'authorization_codes#new'
  delete '/logout' => 'access_tokens#destroy'

  get 'balances', to: 'pages#balances'

  root to: 'pages#welcome'
end
