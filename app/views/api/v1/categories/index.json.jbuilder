json.array! @categories do |category|
  json.extract! category, :id, :name, :color, :household_id
  json.global category.global?
end
