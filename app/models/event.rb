class Event < ApplicationRecord
  validates :title, :happened_on, presence: true
  validates :source, inclusion: { in: %w[manual file blog] }
  validate :url_must_be_http

  scope :chronological, -> { order(:happened_on, :id) }

  private
    def url_must_be_http
      return if url.blank?

      uri = URI.parse(url)
      return if %w[http https].include?(uri.scheme) && uri.host.present?

      errors.add(:url, "must be an HTTP or HTTPS URL")
    rescue URI::InvalidURIError
      errors.add(:url, "must be an HTTP or HTTPS URL")
    end
end
