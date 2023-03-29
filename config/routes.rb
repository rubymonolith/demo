Rails.application.routes.draw do
  resources :users do
    nest :blogs
  end

  resources :blogs do
    nest :posts
  end

  resources :posts

  root to: "users#index"
end
