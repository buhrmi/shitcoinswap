import { page } from 'inertiax-svelte'
import { subscribe } from 'dexiecable'
import db from '~/lib/db'

const subscription = subscribe(db)

let subscribedToken = null
let removeStream = null

$effect.root(() => {
  $effect(() => {
    const streamToken = page.props.stream_token
    if (streamToken == subscribedToken) return
    removeStream?.()
    subscribedToken = streamToken
    if (!streamToken) return
    removeStream = subscription.addStream(streamToken)
  })
})

