StaffPlan::Application.routes.draw do
  
  get "sign_out" => "sessions#destroy", :as => "sign_out"
  get "sign_in" => "sessions#new", :as => "sign_in"
  
  # Users
  resources :users do
    resources :projects, :only => [:update, :create, :destroy], :controller => "users/projects"
    resource :preferences, only: [:update], controller: "users/user_preferences"
  end
  
  # Projects
  resources :projects do
    resources :users, only: [:update, :create, :destroy], controller: "projects/users"
  end
  
  # An assignment is the relation between a user and a project
  # That's where the work weeks reside
  resources :assignments, :only => [:update, :create, :destroy] do
    resources :work_weeks, :only => [:show, :update, :create]
  end
  
  # A project involves a company, a client and a user (through a given assignment) 
  resources :clients

  # Companies have users (members/employees), projects and clients
  resources :companies, only: [:new, :create] do
    resources :memberships, :only => [:create, :update, :destroy]
  end

  # The staff plan is the compound of hours and involvement in projects 
  # by a given user for a given client and a given company
  resources :staffplans, :only => [:show, :index] do
    get 'inactive', :on => :collection
  end
  
  resources :password_resets, except: [:destroy, :show, :index]
  
  resources :registrations, only: [:new, :create] do
    post :complete, on: :collection
    get :confirm, on: :collection
  end
  
  match "/registrations/:token" => "registrations#confirm", via: :get, as: "confirm_registration"
  
  get "/api/companies/:secret" => "api/companies#index", format: :json

  resources :sessions, :only => [:new, :create, :destroy]
  
  match '/my_staffplan' => "staffplans#my_staffplan", via: :get, as: "my_staffplan"
  
  root :to => 'staffplans#my_staffplan'
end
