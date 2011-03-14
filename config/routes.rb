GroupBuying::Application.routes.draw do
  resources :snapshots, :url_checks, :snapshot_diffs
  
  resources :deals do
    post :import, :on => :member
  end
  
  resources :sites do
    resources :deals, :snapshots, :url_checks, :snapshot_diffs, :divisions
  end
  
  root :to => "sites#index"
end
