Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # See how all your routes lay out with "bin/rails routes" or in the browser at "/routes".

  root to: 'welcome#index'
  get '/home' => 'weeks#index', as: 'home'

  resources :weeks, shallow: true do
    member do
      post 'enable'
      post 'disable'
      get 'render_week_plan'
    end

    resources :days do
      resources :shifts
    end
  end

  resources :shifts
  get 'my_shifts' => 'shifts#my_shifts'

  resources :shiftinfos

  resources :people do
    member do
      get 'find_location'
    end
  end

  get    '/signup' => 'people#new',       as: 'signup'
  get    '/login'  => 'sessions#new',     as: 'login'
  post   '/login'  => 'sessions#create'
  delete '/logout' => 'sessions#destroy', as: 'logout'

  get '/help' => 'help#contact', as: 'help'

  namespace :tasks, path: 'sudo', as: nil do
    post 'cachesweep'
  end

end
