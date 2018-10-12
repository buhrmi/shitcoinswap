Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'pages#welcome'
  namespace :admin do
    resources :balance_adjustments
    resources :platforms
    resources :withdrawals
  end

  resources :withdrawals
  # resources :users

  passwordless_for :users
  # , at:'/', as: :auth

  get 'balances', to: 'pages#balances'

end
