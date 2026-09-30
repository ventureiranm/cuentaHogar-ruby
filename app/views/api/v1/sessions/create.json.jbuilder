json.token @token
json.token_type "Bearer"
json.expires_at @api_token.expires_at
json.user do
  json.partial! "api/v1/profiles/user", user: @user
end
