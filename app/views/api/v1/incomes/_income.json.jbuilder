json.extract! income, :id, :description, :received_on, :household_id
json.amount income.amount.to_f
json.scope_name income.scope_name
json.user do
  json.extract! income.user, :id, :name
end
