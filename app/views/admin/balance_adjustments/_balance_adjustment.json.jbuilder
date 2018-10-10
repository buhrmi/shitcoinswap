json.extract! balance_adjustment, :id, :coin_id, :user_id, :change_type, :change_id, :memo, :amount, :created_at, :updated_at
json.url balance_adjustment_url(admin_balance_adjustment, format: :json)
