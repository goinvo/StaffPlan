StaffPlan::Application.routes.draw do
  
  get "sign_out" => "sessions#destroy", :as => "sign_out"
  get "sign_in" => "sessions#new", :as => "sign_in"
  
  resources :users do
    resources :projects, :only => [:update, :create, :destroy],
                         :controller => "users/projects" do
      resources :work_weeks, :only => [:show, :update, :create],
                             :controller => "users/projects/work_weeks"
    end
  end
  
  resources :sessions, :only => [:new, :create, :destroy]
  resource :dashboard, :controller => "dashboard", :only => [:show]
  resources :clients
  resources :projects
  resources :staffplans, :only => [:show]
  
  root :to => 'dashboard#show'
end
