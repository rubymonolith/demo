module Posts
  class BatchesController < ApplicationController
    resources :posts, from: :current_user

    Index = Posts::Controller::Index

    def delete
      @posts.delete_all
    end

    def publish
      @posts.publish_all(publish_at: Time.current)
    end

    protected

    def method_for_action(action_name)
      raise "hell"
    end
  end
end
