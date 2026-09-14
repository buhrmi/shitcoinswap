class Deposit < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :id, :user_id, :asset_id, :wallet_id, :amount, :confirmations ],
    methods: [ :confirmed? ],
    include: {
      asset: Asset::JSON_OPTIONS
    }
  }

  # Confirmations after which a deposit counts as settled. A chain scan stops
  # recounting a deposit once it reaches this.
  CONFIRMATIONS_NEEDED = 2

  belongs_to :user
  belongs_to :asset
  belongs_to :wallet

  syncs_to_dexie via: :user

  def as_json_for_dexie
    as_json(JSON_OPTIONS)
  end

  # Deposits that are still counting up.
  scope :pending, -> { where(confirmations: 0...CONFIRMATIONS_NEEDED) }

  # Deposits that are deep enough to spend.
  scope :confirmed, -> { where(confirmations: CONFIRMATIONS_NEEDED..) }

  # Deposits that have not been added to a balance yet.
  scope :uncredited, -> { where(credited_at: nil) }

  # Adds every confirmed deposit that has not been credited yet to its user's
  # balance. Returns how many were credited.
  def self.credit_confirmed!
    confirmed.uncredited.to_a.each(&:credit!).size
  end

  def confirmed?
    confirmations >= CONFIRMATIONS_NEEDED
  end

  # Adds this deposit to the user's balance, once it is deep enough.
  def credit!
    return if credited_at? || !confirmed?

    transaction do
      balance = user.balances.find_or_create_by!(asset_id: asset_id)
      balance.update!(total: balance.total + amount)
      update!(credited_at: Time.current)
    end
  end
end
