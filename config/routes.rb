GroupBuying::Application.routes.draw do
  resources :deals do
    post :import, :on => :member
  end
  
  resources :sites do
    resources :deals, :snapshots, :url_checks
  end
  
  root :to => "sites#index"
end
