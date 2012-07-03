StaffPlan::Application.routes.draw do
  
  get "sign_out" => "sessions#destroy", :as => "sign_out"
  get "sign_in" => "sessions#new", :as => "sign_in"

  resources :password_resets, except: [:destroy, :show, :index]
  resources :users do
    resources :projects, :only => [:update, :create, :destroy],
                         :controller => "users/projects" do
      resources :work_weeks, :only => [:show, :update, :create],
                             :controller => "users/projects/work_weeks"
    end
  end
  
  resources :registrations, only: [:new, :create] do
    post :complete, on: :collection
    get :confirm, on: :collection
  end
  match "/registrations/:token" => "registrations#confirm", via: :get, as: "confirm_registration"
  
  get "/api/companies/:secret" => "api/companies#index", format: :json

  resources :sessions, :only => [:new, :create, :destroy]
  resources :clients
  
  resources :projects do
    resources :users, only: [:update, :create, :destroy],
                      controller: "projects/users" do
      resources :work_weeks, only: [:show, :update, :create],
                             controller: "projects/users/work_weeks"
    end
  end
  
  resources :staffplans, :only => [:show, :index] do
    get 'inactive', :on => :collection
  end
  resources :companies, only: [:new, :create]
  
  match '/my_staffplan' => "staffplans#my_staffplan", via: :get, as: "my_staffplan"
  
  root :to => 'staffplans#my_staffplan'
end
