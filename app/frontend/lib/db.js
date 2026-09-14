import Dexie from 'dexie'

const db = new Dexie("shitcoinswap");

db.version(1).stores({
  users: "id",
  balances: "id, user_id, asset_id",
  deposits: "id, user_id, asset_id, wallet_id, amount, confirmations"
})

export default db