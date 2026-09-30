json.extract! budget, :id, :household_id, :category_id
json.label budget.label
json.period budget.period.strftime("%Y-%m")
json.amount budget.amount.to_f
json.spent budget.spent.to_f
json.remaining budget.remaining.to_f
json.usage_percentage budget.usage_percentage
json.exceeded budget.exceeded?
