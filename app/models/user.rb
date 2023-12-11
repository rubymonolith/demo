class User < ApplicationRecord
  has_many :blogs
  has_many :posts

  validates :name, presence: true
  validates :email, presence: true

  broadcasts_refreshes
end
