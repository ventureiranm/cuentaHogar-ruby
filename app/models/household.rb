class Household < ApplicationRecord
  CURRENCIES = %w[ ARS USD ].freeze

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :categories, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :reminders, dependent: :destroy

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 80 }
  validates :currency, inclusion: { in: CURRENCIES }

  scope :ordered, -> { order(:name) }

  def summary_for(month = Date.current)
    MonthlySummary.new(self, month)
  end
end
