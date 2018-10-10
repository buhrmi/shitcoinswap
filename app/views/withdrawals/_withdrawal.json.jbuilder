json.extract! withdrawal, :id, :symbol, :user_id, :receiver_address, :transaction_id, :submitted_at, :amount, :status, :tries, :error, :error_at, :signed_transaction, :created_at, :updated_at
json.url withdrawal_url(withdrawal, format: :json)
