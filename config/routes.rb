Septober::Application.routes.draw do

  %w{ index about docs healthz license search statusz varz}.each do |page_action| 
    get "pages/#{page_action}"
  end
  
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login

  # Google style endpoints. Helps with k8s too.
  match 'healthz' => 'pages#healthz' 
  match 'statusz' => 'pages#statusz' 
#  match 'varz' => 'pages#varz'
  match 'varz' => 'pages#varz_testuale'

  resources :sessions
  resources :tags
  
  resources :users do
    collection do
      put :update_attribute_on_the_spot
    end
  end
  
  resources :projects do
    collection do
      put :update_attribute_on_the_spot
    end
    resources :todos do   # how do I select only the sub_project stuff?!? 
      #member do
      #  post 'set_public'
      #  post 'set_private'
      #  post 'set_home'
      #  post 'set_no_home'
      #  post 'set_project_description'
      #  get "procrastinate"
      #end
    end
  end
  resources :projects

  #resources :todos
  resources :todos do
    collection do
      # https://github.com/nathanvda/on_the_spot/issues/26 fixed
      put :update_attribute_on_the_spot
    end
    member do
      %w{sleep done undone toggle procrastinate set_priority set_bookmark quick_create_get set_todo_where
        }.each do |todo_peculiar_action|
        get(todo_peculiar_action.to_s )
      end
      %w{quick_create_post}.each do |todo_post_action|
        post todo_post_action  # TODO!
      end
    end
  end
  #resources :todos
  
  namespace :api do
    get "todos/rss"        => "todos#rss"
    resources :todos do
      member do
        put 'done'     #  lynx --dump http://localhost:3000/api/todos/7.xml -auth=guest:guest
        put 'toggle'   # 201905 bug: ActionController::RoutingError (No route matches "/api/todos/65/toggle.json"):
        put 'edit'
        put 'delete'
      end
    end
  end
  
  
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
  

  resources :projects do
    member do
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
