Rails.application.routes.draw do
  # get 'sessions/create'
  # get 'sessions/destroy'
  # get 'logins/create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :admin do
    resources :balance_adjustments
    resources :platforms
    resources :withdrawals
    resources :assets
  end

  resources :orders
  resources :withdrawals

  # resources :password_resets, only: [:new, :create, :edit, :update]

  # get 'logins/create'
  post '/logins'    => 'logins#create'
  get '/sessions/create'     => 'sessions#create'
  delete '/sessions/destroy' => 'sessions#destroy'
  resources :users

  get 'balances', to: 'pages#balances'

  root to: 'pages#welcome'
end
