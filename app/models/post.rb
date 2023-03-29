class Post < ApplicationRecord
  belongs_to :user
  belongs_to :blog

  validates :title, presence: true
end
