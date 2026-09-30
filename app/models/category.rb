class Category < ApplicationRecord
  belongs_to :household, optional: true
  has_many :expenses, dependent: :nullify
  has_many :budgets, dependent: :destroy

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 40 },
                   uniqueness: { scope: :household_id, case_sensitive: false }
  validates :color, format: { with: /\A#\h{6}\z/, message: "debe ser un color hexadecimal (ej. #2F4F4A)" }

  scope :ordered, -> { order(:name) }
  scope :global, -> { where(household_id: nil) }
  scope :available_for, ->(household_ids) { where(household_id: [ nil, *household_ids ]) }

  def global?
    household_id.nil?
  end

  def display_name
    global? ? name : "#{name} (#{household.name})"
  end
end
