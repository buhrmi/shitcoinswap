import { liveQuery } from 'dexie'
import { page } from 'inertiax-svelte'
import { derived, toStore } from 'svelte/store'

import db from '~/lib/db'

export const userId = toStore(() => page.props.current_user_id)

/**
 * Like Dexie's `liveQuery`, but the querier receives the current `userId`
 * and the query is re-created whenever `userId` changes.
 *
 * The querier is not called while logged out, which also avoids Dexie
 * throwing on null/undefined keys (`where(...).equals(null)`).
 *
 * @example
 *   export const balances = userQuery(
 *     (id) => db.balances.where("user_id").equals(id).toArray(),
 *     []
 *   )
 *
 * @param {(userId: number) => unknown} querier
 * @param {unknown} [initialValue] emitted while logged out, before the first result
 */
export function userQuery(querier, initialValue = undefined) {
  return derived(userId, ($userId, set) => {
    if ($userId == null) {
      set(initialValue)
      return
    }

    const subscription = liveQuery(() => querier($userId)).subscribe({
      next: set,
      error: (error) => console.error("userQuery failed", error)
    })

    return () => subscription.unsubscribe()
  }, initialValue)
}

export const currentUser = userQuery((id) =>
  db.users.where("id").equals(id).first()
)

export const balances = userQuery((id) =>
  db.balances.where("user_id").equals(id).toArray()
)

export const deposits = userQuery((id) =>
  db.deposits.where("user_id").equals(id).toArray(), []
)