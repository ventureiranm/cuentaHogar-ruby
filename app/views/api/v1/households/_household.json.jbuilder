json.extract! household, :id, :name, :currency
json.members household.memberships do |membership|
  json.id membership.user_id
  json.name membership.user.name
  json.initials membership.user.initials
  json.role membership.role
end
