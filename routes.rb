  namespace(:apis) do |apis|
    apis.resources :users, :collection => {:authenticate => :post}
    apis.resources :projects, :member => {:maintenances => :get } do |projects|
      projects.resources :issues, :member => {:comments => :get, :details => :get, :add_comment => :post}
    end
  end
