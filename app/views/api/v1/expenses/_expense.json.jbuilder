json.extract! expense, :id, :description, :spent_on, :recurring, :source, :notes, :household_id
json.amount expense.amount.to_f
json.scope_name expense.scope_name
json.pending_review expense.pending_review?
json.user do
  json.extract! expense.user, :id, :name
end
if expense.category
  json.category expense.category, :id, :name, :color
else
  json.category nil
end
if expense.receipt.attached?
  json.receipt_url rails_blob_url(expense.receipt)
else
  json.receipt_url nil
end
json.created_at expense.created_at
