class Blog < ApplicationRecord
  belongs_to :user, required: true
  has_many :posts

  validates :title, presence: true
end
