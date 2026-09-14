class Balance < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :id, :user_id, :asset_id, :total, :available, :locked ],
    include: {
      asset: Asset::JSON_OPTIONS
    }
  }
  belongs_to :user
  belongs_to :asset

  validates :user_id, uniqueness: { scope: :asset_id }

  syncs_to_dexie via: :user

  # available is never stored independently: it is whatever money the user
  # has that isn't locked behind a funded buy order.
  before_save { self.available = (total || 0) - (locked || 0) }

  # Serialized for Dexie; the store is keyed by the AR id so syncs_to_dexie's
  # create/update/delete ops (which key by id) apply correctly.
  #
  # asset_name is denormalized so the client can render labels without
  # syncing the assets table. It is only sent on create/snapshot (updates
  # slice to saved_changes), which is fine while asset names are static.
  def as_json_for_dexie
    as_json(JSON_OPTIONS)
  end
end
