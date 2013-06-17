Badi2010::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes"

  root  to: 'welcome#index', via: :get 
  match '/home' => 'weeks#index', via: :get, as: 'home'

  # handle legacy routes
  match '/badi2010' => redirect('/'), anchor: false

  match 'weeks/enable/:id/:saison_name'  => 'weeks#enable',  as: 'week_enable'
  match 'weeks/disable/:id/:saison_name' => 'weeks#disable', as: 'week_disable'

  match 'sudo/imagine' => 'tasks#imagine', as: 'imagine'
  match 'sudo/imagine' => 'tasks#imagine', as: 'imagine'
  match 'sudo/cachesweep' => 'tasks#cachesweep', as: 'cachesweep'


  resources :weeks, shallow: true do
    resources :days do
      resources :shifts
    end
  end
  resources :shifts
  resources :shiftinfos

  resources :people
  
  match '/myshifts' => 'shifts#my_shifts', as: 'myshifts'

  resource :session, only: [:new, :create, :destroy]
#  match '/activate/activation_code': 'accounts#activate', as: 'activate', activation_code: nil
  match '/signup' => 'people#new', as: 'signup'
  match '/login' => 'sessions#new', as: 'login'
  match '/logout' => 'sessions#destroy', as: 'logout'

  match '/help' => 'help#contact', as: 'help'

  # Install the default routes as the lowest priority.
  # TODO: This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'




  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  # This route can be invoked with purchase_url(id: product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
  #       get 'recent', on: :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
