class DexieChannel < ApplicationCable::Channel
  include DexieCable

  def subscribed_to(record, params)
    case record
    when User
      table("users").put(record.as_json(User::PRIVATE_JSON_OPTIONS))

      table("balances").bulkPut(record.balances.includes(:asset).map(&:as_json_for_dexie))

      table("deposits").bulkPut(record.deposits.includes(:asset).map(&:as_json_for_dexie))

    end
  end
end
