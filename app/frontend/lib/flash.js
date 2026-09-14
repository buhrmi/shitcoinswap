import { toast, Toaster } from 'svelte-sonner'
import { mount } from "svelte"
import { router } from 'inertiax-svelte'

function handleFlash(flash) {
  if (flash.notice) toast.success(flash.notice)
  if (flash.alert) toast.error(flash.alert)
}

document.addEventListener('inertia:flash', (event) => {
  const flash = event.detail.flash
  handleFlash(flash)
})

mount(Toaster, {
  target: document.body,
  props: {
    theme: 'dark',
    richColors: true,
    position: 'top-center',
  },
})