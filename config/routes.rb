Groupster::Application.routes.draw do
  resources :mail_updates

  match "/sites/coupons_count" => "sites#coupons_count"
  
  resources :trends, :only => [:index]

  resources :snapshots, :only => [:index, :show]

  resources :divisions, :only => [:index, :show]

  match '/deals/geo/geocode' => 'deals_geo#geocode' # Could be a member of resource 'deals' but want to work on a different controller for now
  match '/deals/geo' => 'deals_geo#index' # Could be a member of resource 'deals' but want to work on a different controller for now
  resources :deals, :only => [:index, :show]

  resources :sites, :only => [:index, :show] do
    resources :deals, :only => [:index, :show] do
      resources :snapshots, :only => [:index, :show]
    end
    
    resources :divisions, :only => [:index, :show] do
      resources :deals, :only => [:index, :show]
    end
  end
  
  # Admin routes
  namespace :admin do
    root :to => 'sites#index'
    
    match '/sites/:id(/page/:page(/search/:search))' => 'sites#show'
    
    match "/deals/export" => "deals#export"
    match "/:model/table" => "application#table"
    
    resources :snapshots, :only => [:index, :show]

    resources :divisions, :only => [:index, :show]

    resources :deals, :only => [:index, :show]

    resources :sites, :only => [:index, :show] do
      resources :deals, :only => [:index, :show] do
        resources :snapshots, :only => [:index, :show]
      end
      
      resources :divisions, :only => [:index, :show] do
        resources :deals, :only => [:index, :show]
      end
    end
  end

  devise_for :users
  devise_scope :user do
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
    get 'signup', :to => 'devise/registrations#new'
  end
  

  root :to => 'sites#index'
end
