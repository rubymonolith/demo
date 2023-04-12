Rails.application.routes.draw do
  resources :users do
    nest :blogs
    create :session
  end

  resources :blogs do
    nest :posts
  end

  resources :posts

  resources :sessions

  root to: "users#index"
end
