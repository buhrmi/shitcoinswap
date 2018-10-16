json.extract! authorization_code, :id, :user_id, :token, :used_at, :created_at, :updated_at
json.url authorization_code_url(authorization_code, format: :json)
