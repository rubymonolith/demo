class Blog < ApplicationRecord
  belongs_to :user, required: true, touch: true
  has_many :posts


  validates :title, presence: true

  broadcasts_refreshes
end
