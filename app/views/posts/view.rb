module Posts
  class View < ApplicationView
    attr_writer :post

    turbo method: :morph do
      stream_from @post, @current_user
    end
  end
end