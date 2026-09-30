json.extract! household, :id, :name, :currency
json.members household.memberships, partial: "api/v1/memberships/member", as: :membership
