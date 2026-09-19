<script>
  import { authenticate } from '~/lib/auth.svelte.js'
  const {
    text = "Continue with"
  } = $props()
</script>

<div class="divider">or</div>

<!-- <button class="btn secondary mb-2" onclick={() => authenticate('tiktok-loginkit', flow)}>
  <img src={"/vendor/tiktok.svg"} alt="TikTok" class="h-6"/>
  {text} TikTok
</button> -->

<!-- <button class="btn secondary mb-2" onclick={() => authenticate('twitter')}>
  <img src="~/assets/x.svg" alt="X" class="h-6"/>
  {text} X
</button> -->

<button class="btn secondary mb-2" onclick={() => authenticate('discord')}>
  <img src="~/assets/discord.png" alt="Discord" class="h-5"/>
  {text} Discord
</button>

<button class="btn secondary" onclick={() => authenticate('google_oauth2')}>
  <img src="~/assets/google.png" alt="Google" class="h-6"/>
  {text} Google
</button>
