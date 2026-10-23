class Event < ApplicationRecord
  SOURCES = %w[ manual file blog ].freeze

  validates :title, presence: true
  validates :happened_on, presence: true
  validates :source, inclusion: { in: SOURCES }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[ http https ]), message: "must be an http(s) URL" }, allow_blank: true

  scope :chronological, -> { order(:happened_on, :id) }
end
