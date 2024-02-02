module Posts
  class New < View
    def title = "New Post"

    def template
      render Form.new(Post.new)
    end
  end
end