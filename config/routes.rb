ActionController::Routing::Routes.draw do |map|

  map.week_enable  'weeks/enable/:id/:saison_name',  :controller => 'weeks', :action => 'enable'
  map.week_disable 'weeks/disable/:id/:saison_name', :controller => 'weeks', :action => 'disable'
  
  map.imagine    'sudo/imagine',    :controller => 'tasks', :action => 'imagine'
  map.cachesweep 'sudo/cachesweep', :controller => 'tasks', :action => 'cachesweep'

  map.resources :weeks, :shallow => true do |week|
    week.resources :days do |shift| 
      shift.resources :shifts
    end
  end
  map.resources :shifts
  map.resources :shiftinfos

  map.resources :people
  map.myshifts '/myshifts', :controller => 'shifts', :action => 'my_shifts'

  map.resource :session
#  map.activate '/activate/:activation_code', :controller => 'accounts', :action => 'activate', :activation_code => nil
  map.signup '/signup', :controller => 'people',   :action => 'new'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.help '/help', :controller => 'help', :action => 'contact'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "welcome"
  map.home '/home', :controller => 'weeks'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
