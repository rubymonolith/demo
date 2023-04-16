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

    def title = "People"
    def subtitle = "Create users and sign in"

    def template(&)
      section do
        ul do
          @users.each do |user|
            li { show(user, :name) }
          end
        end
        create(@users, role: "button")
      end
    end
  end

  class Show < ApplicationView
    attr_writer :user

    def title = @user.name
    def subtitle = @user.email

    def template(&)
      list(@user.blogs) do |blog|
        show(blog, :title)
      end
      nav do
        create(@user.blogs, role: "button")
        link_to("/users/sessions") { "Login" }
        edit(@user, role: "secondary")
      end
    end
  end

  class New < ApplicationView
    attr_writer :user

    def title = "Create user"

    def template(&)
      render Form.new(@user)
    end
  end

  class Edit < ApplicationView
    attr_writer :user

    def title = "Edit #{@user.name}"

    def template(&)
      render Form.new(@user)
    end
  end
end
