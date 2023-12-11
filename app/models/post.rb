class Post < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :blog, touch: true

  validates :title, presence: true

  attribute :publish_at, Inputomatic::DateTime.new

  broadcasts_refreshes

  def status
    status = if publish_at.nil?
      "Draft"
    elsif publish_at > Time.current
      "Scheduled"
    else
      "Published"
    end

    ActiveSupport::StringInquirer.new(status)
  end
end
