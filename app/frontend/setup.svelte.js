import { page } from 'inertiax-svelte'
import { subscribe } from 'dexiecable'
import db from '~/lib/db'
import { router } from "inertiax-svelte"

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

// this event is fired from the OAuth popup window
window.addEventListener('message', function(event) {
  if (event.data == 'session-created') {
    router.reload()
  }
})