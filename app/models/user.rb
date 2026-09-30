class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :households, through: :memberships
  has_many :expenses, dependent: :destroy
  has_many :incomes, dependent: :destroy
  has_many :reminders, dependent: :nullify

  # admin: entra al back-office. member: usuario final que usa la API.
  enum :role, { member: 0, admin: 1 }

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 80 }
  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  scope :ordered, -> { order(:name) }

  def initials
    name.to_s.split.first(2).map { |part| part[0] }.join.upcase
  end

  def member_of?(household)
    return false if household.nil?

    memberships.exists?(household_id: household.id)
  end
end
