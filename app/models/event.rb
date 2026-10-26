class Event < ApplicationRecord
  SOURCES = %w[manual file blog].freeze

  normalizes :category, with: ->(category) { category.squish.presence }

  validates :title, :happened_on, presence: true
  validates :category, length: { maximum: 50 }
  validates :source, inclusion: { in: SOURCES }
  validate :url_must_be_http

  scope :chronological, -> { order(:happened_on, :id) }

  def self.categories
    where.not(category: nil).distinct.order(:category).pluck(:category)
  end

  # Categories in the order they were first used, so a new category never
  # takes the place (and the color) of an existing one.
  def self.categories_by_first_use
    where.not(category: nil).group(:category).order(Arel.sql("MIN(id)")).pluck(:category)
  end

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
