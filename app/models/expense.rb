class Expense < ApplicationRecord
  include HouseholdScoped

  RECEIPT_CONTENT_TYPES = %w[ image/jpeg image/png application/pdf ].freeze
  MAX_RECEIPT_SIZE = 5.megabytes

  belongs_to :category, optional: true
  has_one_attached :receipt

  # imported: viene de un resumen bancario y puede quedar sin categoría.
  enum :source, { manual: 0, imported: 1 }

  validates :spent_on, presence: true
  validate :category_must_match_household
  validate :receipt_must_be_valid

  scope :recent_first, -> { order(spent_on: :desc, id: :desc) }
  scope :in_month, ->(date) { where(spent_on: date.to_date.all_month) }
  scope :pending_review, -> { where(category_id: nil) }

  def pending_review?
    category_id.nil?
  end

  private
    def category_must_match_household
      return if category.nil? || category.global? || category.household_id == household_id

      errors.add(:category, "no pertenece a este hogar")
    end

    def receipt_must_be_valid
      return unless receipt.attached?

      unless receipt.blob.content_type.in?(RECEIPT_CONTENT_TYPES)
        errors.add(:receipt, "debe ser una imagen JPG/PNG o un PDF")
      end
      errors.add(:receipt, "no puede superar los 5 MB") if receipt.blob.byte_size > MAX_RECEIPT_SIZE
    end
end
