desc "Run deposit scanner in background"
task scan_for_deposits: [:environment] do
  while true
    Platform.all.each do |platform|
      puts "Scanning blocks on #{platform.name}"
      platform.scan_for_deposits!
    end
    
    # Create Consolidation withdrawals for every new deposit
    # A "Consolidation Withdrawal" is a transfer from the deposit address to the hot wallet
    # XXX: only do this if it's worthwhile...
    for deposit in Deposit.where(withdrawal_to_hotwallet: nil)
      puts "Creating withdrawal into hotwallet for deposit #{deposit.id}"
      platform = deposit.asset.platform
      withdrawal = Withdrawal.create!(asset: deposit.asset, amount: deposit.amount, receiver_address: platform.hot_wallet_address, sender_address: deposit.address.address)
      deposit.update_attribute :withdrawal_to_hotwallet, withdrawal
    end
    Status.update_all last_deposit_scan_at: Time.now
    sleep 69
  end
end