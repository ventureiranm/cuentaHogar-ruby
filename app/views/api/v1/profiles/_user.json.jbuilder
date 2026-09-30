json.extract! user, :id, :name, :email_address, :role
json.initials user.initials
json.households user.memberships.includes(:household) do |membership|
  json.id membership.household_id
  json.name membership.household.name
  json.role membership.role
end
