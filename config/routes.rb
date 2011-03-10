GroupBuying::Application.routes.draw do
  resources :deals do
    post :import, :on => :member
  end
  
  resources :sites do
    resources :deals, :snapshots
  end
  
  root :to => "sites#index"
end
