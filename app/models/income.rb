class Income < ApplicationRecord
  include HouseholdScoped

  validates :received_on, presence: true

  scope :recent_first, -> { order(received_on: :desc, id: :desc) }
  scope :in_month, ->(date) { where(received_on: date.to_date.all_month) }
end
