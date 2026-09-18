Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resource :user
  resources :verifications
  resources :password_resets

  resources :assets
  resources :networks do
    resources :assets
  end

  resources :deposits
  resource :session

  # OmniAuth callback routes
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"

  # Static routes
  inertia "/terms" => "static/terms"
  inertia "/privacy" => "static/privacy"

  # Defines the root path route ("/")
  root "assets#index"
end
