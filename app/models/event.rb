class Event < ApplicationRecord
  validates :title, :happened_on, presence: true
  validates :source, inclusion: { in: %w[manual file blog] }
  validates :url, format: { with: /\Ahttps?:\/\/[^\s\/?#]+[^\s]*\z/i, message: "must be an HTTP or HTTPS URL" }, allow_blank: true

  scope :chronological, -> { order(:happened_on, :id) }
end
