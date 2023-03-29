class UsersController < ApplicationController
  resources :users

  class Form < ApplicationForm
    def template(&)
      field :name
      field :email
      submit
    end
  end

  class Index < ApplicationView
    attr_writer :users

    def template(&)
      h1 { "People" }
      section do
        ul do
          @users.each do |user|
            li { show(user, :name) }
          end
        end
        create(@users)
      end
    end
  end

  class Show < ApplicationView
    attr_writer :user

    def template(&)
      h1 { @resource.name }
      p { @user.inspect }
      ul do
        @user.blogs.each do |blog|
          li do
            helpers.link_to blog.title, blog
          end
        end
      end
      nav do
        create(@user.blogs, role: "button")
        edit(@user, role: "secondary")
      end
    end
  end

  class New < ApplicationView
    attr_writer :user

    def template(&)
      h1 { "Create User" }
      render Form.new(@user)
    end
  end

  class Edit < ApplicationView
    attr_writer :user

    def template(&)
      h1 { "Edit #{@user.name}" }
      render Form.new(@user)
    end
  end
end
