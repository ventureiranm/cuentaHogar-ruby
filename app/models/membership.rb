class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :household

  # owner: administra el hogar (ej. "Administradora del hogar" en la PWA).
  enum :role, { member: 0, owner: 1 }

  validates :user_id, uniqueness: { scope: :household_id, message: "ya es miembro de este hogar" }
end
