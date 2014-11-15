Rails.application.routes.draw do
  get 'api/index'

  resources :notifications

  resources :tours

  resources :comments

  resources :categories

  resources :users

  resources :posts do
    resources :assets
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'api#index'

  get '/posts_by_user/:user_id' => 'posts#posts_by_user' 
  post '/posts_nearby' => 'posts#posts_nearby' 
  post '/favorite' => "posts#favorite"
  get '/n_posts/:n' => 'posts#n_posts'
  post '/upload_assets' => 'posts#upload_assets'
  get '/popular_posts/:n' => 'posts#popular_posts'

  get '/followed_posts/:user_id/:n' => 'posts#followed_posts'

  post '/login_facebook' => 'users#create_facebook' 
  post '/login_twitter' => 'users#create_twitter' 
  post '/login_common' => 'users#login_common' 

  delete '/favorite' => "posts#undo_favorite"

  get '/top_users/:n' => "users#top_users"
  post '/follow_user' => "users#follow_user"
  delete '/follow_user' => "users#unfollow_user"
  get '/favorites/:id' => 'users#favorites'
  get '/followers/:id' => 'users#followers'
  get '/followed/:id' => 'users#followed'

  post '/register_common' => 'users#create_common' 
  post '/random_tour' => 'posts#random_tour'

  post '/preferences_posts' => 'posts#preferences_posts'

  get '/search/:search_text' => 'posts#search_post'

  #MOBILE
  post '/posts_mobile' => 'posts#create_mobile'
  post '/assets_mobile/:id' => 'posts#assets_mobile'

  post 'comment' => 'comments#comment'

  #OPEN DATA
  get '/v1/places/' => 'posts#places_near'
  get '/v1/popular_places/' => 'posts#places_near'
  
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
