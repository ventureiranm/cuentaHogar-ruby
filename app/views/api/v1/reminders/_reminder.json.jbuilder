json.extract! reminder, :id, :household_id, :title, :due_on, :paid_at
json.amount reminder.amount&.to_f
json.household_name reminder.household.name
json.days_until_due reminder.days_until_due
json.status reminder.status
