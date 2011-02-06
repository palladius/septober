Septober::Application.routes.draw do

  %w{ index docs about search license}.each do |page_action| 
    get "pages/#{page_action}"
  end
  
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login

  resources :sessions
  resources :users
  #resources :todos
  
  resources :projects do
    resources :todos # how do I select only the sub_project stuff?!? 
    member do
      #get 'short'
      post 'set_public'
      post 'set_private'
      post 'set_home'
      post 'set_no_home'
      post 'set_project_description'
      get "procrastinate"
    end
  end
  resources :todos do
    member do
      #get 'short'
      get  'done'
      get  'undone'
      get  'toggle'
      get  'set_priority'
      get  'set_bookmark'
      post 'quick_create_post'  # TODO!
      get  'quick_create_get'
      get  'procrastinate'
      # From inlien edit plugin (!!!)
      #get  'set_todo_name'
      get  'set_todo_where'
      #get  'set_todo_description'
    end
  end
  
  namespace :api do
    resources :todos do
      member do
        put  'done'     #  lynx --dump http://localhost:3000/api/todos/7.xml -auth=guest:guest
        #get  'done'
        #post 'done'
       # put :generic_action
      #  get 'toggle'
      end
    end
  end
  
  # TODO put into resource
  #match "/todos/:id/toggle"        => 'todos#toggle'
  #match "/todos/:id/done"          => 'todos#done'
  #match "/todos/:id/undone"        => 'todos#undone'
  #match "/todos/:id/set_priority"  => 'todos#set_priority'
  
  #####################################
  ### RicAddons::Routes
  # TODO move to some magic function.. sth like
  #map.ric_addons
  # include RicAddons
  # RicAddons::ric_addons_set_routes(self)
  # # Routes version 1.0.2
  get "ric_addons"        => "ric_addons#index"
  get "ric_addons/about"
  get "ric_addons/index"
  get "ric_addons/search"
  get "ric_addons/test"
  ### /RicAddons::Routes
  ####################################
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :projects do
    member do
  #       get 'short'
  #       post 'toggle'
      get :procrastinate
    end
  end
  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #namespace :api do
  ##     # Directs /admin/products/* to Admin::ProductsController
  ##     # (app/controllers/admin/products_controller.rb)
  #  resources :todos
  #end

  namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
    resources :todos
  end


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "todos#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
