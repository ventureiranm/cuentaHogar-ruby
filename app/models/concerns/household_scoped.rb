# Comportamiento común de los movimientos (gastos e ingresos):
# pertenecen a un usuario y, opcionalmente, a un hogar.
# Sin hogar = movimiento del ámbito "Personal".
module HouseholdScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :household, optional: true

    validates :description, presence: true, length: { maximum: 120 }
    validates :amount, numericality: { greater_than: 0, less_than: 10_000_000_000 }
    validate :user_must_belong_to_household

    scope :personal, -> { where(household_id: nil) }
    scope :visible_to, lambda { |user|
      where(household_id: user.household_ids).or(where(household_id: nil, user_id: user.id))
    }
  end

  def personal?
    household_id.nil?
  end

  def scope_name
    household&.name || "Personal"
  end

  private
    def user_must_belong_to_household
      return if household.nil? || user.nil? || user.member_of?(household)

      errors.add(:household, "no incluye a #{user.name}")
    end
end
