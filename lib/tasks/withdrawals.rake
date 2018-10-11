desc "This is a never-ending background task that submits requested withdrawals to the blockchain"
task withdrawals: [:environment] do
  while true
    for withdrawal in Withdrawal.where("status IS NULL or status = 'error' and tries < 10")
      withdrawal.with_lock do
        withdrawal.execute!
      end
    end
    for withdrawal in Withdrawal.where("status = 'submitted'")
      # TODO: check confirmations on the blockchain
    end
    sleep 15
  end
end