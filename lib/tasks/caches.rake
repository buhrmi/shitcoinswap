desc "Build trade volume caches so that we can sort the assets easily by trade volume"
task caches: [:environment] do
  while true
    assets = Asset.all
    
    for base_asset in assets
      for quote_asset in Asset.quotable
        volume = base_asset.volume24h(quote_asset)
        CachedVolume.create!(base_asset: base_asset, quote_asset: quote_asset, period: '24h', sum_trades: volume)
      end
    end
    # wait 5 minutes before running again
    sleep 5 * 60
    Status.update_all last_withdrawals_ran_at: Time.now
  end
end