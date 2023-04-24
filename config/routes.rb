def batch(*actions, **kwargs)
  collection do
    namespace :batch do
      get :index
      post :update
      actions.each do |action|
        post action
      end
    end
  end
end

Rails.application.routes.draw do
  resources :users, except: :destroy do
    nest :blogs
    create :session
  end

  resources :blogs do
    nest :posts do
      batch :delete, :publish
    end
  end

  resources :posts

  resources :sessions

  root to: "blogs#index"
end
