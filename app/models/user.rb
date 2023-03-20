class User < ApplicationRecord
  has_many :blogs
  has_many :posts, through: :blogs
end
