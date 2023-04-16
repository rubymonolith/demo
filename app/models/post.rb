class Post < ApplicationRecord
  belongs_to :user
  belongs_to :blog

  validates :title, presence: true

  attribute :publish_at, Inputomatic::DateTime.new

  def status
    status = if publish_at.nil?
      "Draft"
    elsif publish_at < Time.now
      "Published"
    else
      "Unpublished"
    end

    ActiveSupport::StringInquirer.new(status)
  end
end
