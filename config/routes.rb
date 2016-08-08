# -*- encoding : utf-8 -*-
Rails.application.routes.draw do

  root to: "toppage#index"

  get  "logout" => "sessions#destroy", as: "logout"
  get  "login" => "sessions#new", as: "login"
  get  "signup" => "users#new", as: "signup"

  post "articles/preview" => "articles#preview", as: "preview_article"
  post "articles/recommend" => "articles#recommend", as: "recommend_article"
  post "articles/favor" => "articles#favor", as: "favor_article"
  post "articles/:article_id/preview" => "feedbacks#preview", as: "preview_feedback"
  get  "articles/tags/:tag_id" => "articles#articles_by_tag", as: "articles_by_tag"
  get  "articles/user/:user_id" => "articles#articles_by_user", as: "articles_by_user"
  get  "articles/user/:user_id/favorites" => "articles#favorite_articles", as: "favorite_articles"
  get  "articles/user/:user_id/recommend_articles" => "articles#recommend_articles", as: "recommend_articles"
  get  "articles/user/:user_id/recommend_feedback" => "articles#recommended_feedbacks", as: "recommend_feedbacks"
  get  "articles/user/:user_id/recommended_articles" => "articles#recommended_articles", as: "recommended_articles"
  get  "articles/user/:user_id/recommended_feedbacks" => "articles#recommended_feedbacks", as: "recommended_feedbacks"
  get  "articles/more" => "articles#show_more", as: "more_articles"
  get  "articles/recent" => "articles#recently_created_articles", as: "recently_articles"
  get  "articles/search" => "articles#search"

  post "feedbacks/recommend" => "feedbacks#recommend", as: "recommend_feedback"

  get  "toppage/more_tags_ranking" => "toppage#more_tags_ranking", as: "more_tags_ranking"
  get  "toppage/more_article_users_ranking" => "toppage#more_article_users_ranking", as: "more_article_users_ranking"
  get  "toppage/more_feedback_users_ranking" => "toppage#more_feedback_users_ranking", as: "more_feedback_users_ranking"
  get  "toppage/more_recommended_articles_ranking" => "toppage#more_recommended_articles_ranking", as: "more_recommended_articles_ranking"
  get  "toppage/more_favorite_articles_ranking" => "toppage#more_favorite_articles_ranking", as: "more_favorite_articles_ranking"

  resources :articles do
    resources :feedbacks, except: [:show, :index]
  end

  resources :users
  resources :sessions
  resources :tags, except: :show
  # resources :feedbacks

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
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
