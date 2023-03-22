class UsersController < ApplicationController
  include Assignable
  include Phlexable

  assign :users

  class Index < ApplicationView
    attr_writer :users

    def template(&)
      h1 { "People" }
      section do
        ul {
          @users.each { |user|
            li { helpers.link_to(user.name, user) }
          }
        }
        a(href: new_user_path) { "Create user" }
      end
    end
  end

  class Show < ApplicationView
    attr_writer :user

    def template(&)
      h1 { @user.name }
      section { @user.inspect }
      a(href: new_user_blog_path(@user)) { "Create Blog" }
    end
  end

  class New < ApplicationView
    attr_writer :user

    def template(&)
      h1 { "Create User" }
      section { @user.inspect }
    end
  end
end
