# -*- encoding : utf-8 -*-
RailsPrototype::Application.routes.draw do
  # devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'main#index'

  get 'help' => 'help#index', as: :help # creates learn_path and learn_url
  get 'challenge' => 'challenge#index', as: :challenge # creates challenge_path and challenge_url
  get 'learn' => 'game#index', as: :learn # creates learn_path and learn_url
  get 'learn/:name' => 'game#learn' # creates learn_path and learn_url
  get 'challenge/:file' => 'challenge#index' # creates challenge_path and challenge_url
  get 'help/:file' => 'help#index' # creates help_path and help_url
  get 'learn/new' => 'game#new' # creates learn_path and learn_url

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
