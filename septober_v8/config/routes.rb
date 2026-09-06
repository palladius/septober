Rails.application.routes.draw do
  root "todos#index"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  get "logout", to: "sessions#destroy", as: :logout
  get "signup", to: "users#new", as: :signup

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create, :edit, :update, :show]

  resources :projects do
    member do
      get :procrastinate
    end
    resources :todos
  end

  resources :todos do
    member do
      get :sleep
      get :done
      get :undone
      get :toggle
      get :procrastinate
      get :set_priority
      get :set_bookmark
      get :set_todo_where
    end
  end

  # Health checks
  get "healthz", to: "pages#healthz"
  get "statusz", to: "pages#statusz"
  get "varz", to: "pages#varz"
end
