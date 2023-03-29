# README

Demonstrates the use of a Phlex app that maps closely to the database tables of an application.

## Embedded Phlex views in controllers

Phlex classes are used to render HTML views. Now Erb, partials, or templates are used. This demonstrates the feasiblity of component-driven application development with Rails.

Here's an example of a controller with embedded Phlex classes:

```ruby
class Users::BlogsController < ApplicationController
  resources :blogs, from: :current_user

  class New < ApplicationView
    attr_writer :blog

    def template
      h1 { "Create a new blog" }
      render BlogsController::Form.new(@blog)
    end
  end

  class Index < ApplicationView
    attr_writer :blogs, :current_user

    def template(&)
      h1 { "#{@current_user.name}'s Blogs" }
      section do
        ul {
          @blogs.each { |blog|
            li { show(blog, :title) }
          }
        }
        create(@current_user.blogs, role: "button")
      end
    end
  end
end
```

## Shallow RESTful applications

This project picks up where Rails left off with Shallow RESTful routes. [Boring Rails](https://boringrails.com/tips/rails-scoped-controllers-sharing-code) does a decent job covering it, but as you'll see there's a lot to be desired.

But first, it's important to understand the use of modules in controllers to manage the context in which things are created.

For example, when creating a post for a blog, the URL would be `/blogs/100/posts/new`, which maps to the controller at `Blogs::PostsController#new`, which eventually creates the object via `User.find(session[:user_id]).blogs.find(params[:blog_id]).build(params.require(:post).permit(:title, :post)).create!` in ActiveRecord.

It's really annoying typing that out every single time, so let's see how we can do better.

### Route helpers

Routes look like this:

```ruby
Rails.application.routes.draw do
  resources :blogs do
    nest :posts
  end
end
```


#### The old way

If you did it the old way, you'd end up littering your routes file with `scope module: ...` calls, which makes the situation less readable.

```ruby
Rails.application.routes.draw do
  resources :blogs do
    scope module: :blogs do
      resources :posts
    end
  end
end
```

### Link helpers

Link helpers are actually RESTful. Want to show a blog and have the link text be the title of the blog?

```ruby
show(@blog, :title)
```
Need to edit that blog?

```ruby
edit(@blog)
```

The text of the link defaults to "Edit Blog", but you can make it whatever you want by passing in a block:

```ruby
edit(@blog) { "Edit the #{@blog.title} Blog" }
```

Same for deleting the blog.

```ruby
delete(@blog)
```

Where things get interesting is creating stuff. If you pass a relationship into the blog helper, it will be able to infer its parent. For example, this

```ruby
create(@blog.posts)
```

Will understand that it should link to the `Blog::PostsController#new` action because it can reflect on the relationship.

Similarly if you pass in an unpersisted model.

```ruby
create(@blog)
```

It will figure it out.

#### The old way

Rails started off with reasonable URL helpers. If you wanted to delete a resource, you could do something like this:

```erb
<%=link_to "Delete Blog", @blog, method: :delete %>
```

But then Turbo came along and for some reason things got more complicated because "consistency", so we ended up with this:

```erb
<%= link_to "Delete Blog", @blog, data: {"turbo-method": :delete } %>
```

Gah! Compare that to the new way:

```ruby
delete(@blog)
```

Creation is where things get more interesting, you're probably use to this:

```ruby
<%= link_to "Create Blog Post", new_blog_post_path(@blog) %>
```

The new way requires much less typing:

```ruby
create(@blog.posts) { "Create Blog Post" }
```

### Controller helpers

Nested RESTful controllers come with a