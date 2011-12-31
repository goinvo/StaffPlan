StaffPlan::Application.routes.draw do
  
  get "sign_out" => "sessions#destroy", :as => "sign_out"
  get "sign_in" => "sessions#new", :as => "sign_in"
  
  resources :users do
    resources :projects, :only => [:update, :create, :destroy],
                         :controller => "users/projects"
  end
  
  resources :sessions, :only => [:new, :create, :destroy]
  resource :dashboard, :controller => "dashboard", :only => [:show]
  
  resources :staffplans, :only => [:show]
  
  root :to => 'dashboard#show'
end
