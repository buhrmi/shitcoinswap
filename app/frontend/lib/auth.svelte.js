import { router } from "inertiax-svelte"

export function authenticate(provider, flow = "login") {
  const width = 500;
  const height = 720;
  const left = (screen.width - width) / 2;
  const top = (screen.height - height) / 2;
  const windowFeatures = `width=${width},height=${height},left=${left},top=${top}`;
  
  window.open(`/session/new?provider=${provider}&flow=${flow}`, '_blank', windowFeatures);
}

// this event is fired from the OAuth popup window
window.addEventListener('message', function(event) {
  if (event.data == 'session-created') {
    router.reload()
  }
})
