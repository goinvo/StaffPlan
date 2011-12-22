StaffPlan::Application.routes.draw do
  
  get "sign_out" => "sessions#destroy", :as => "sign_out"
  get "sign_in" => "sessions#new", :as => "sign_in"
  
  resources :users
  resources :sessions
  resource :dashboard, :controller => "dashboard", :only => [:show]
  
  root :to => 'dashboard#show'
end
