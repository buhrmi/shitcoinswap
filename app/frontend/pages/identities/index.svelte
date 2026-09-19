<script>
  import { useFrameRouter } from 'inertiax-svelte'
  import { authenticate } from '~/lib/auth.svelte.js'

  const router = useFrameRouter()

  const {
    identities = []
  } = $props()

  function hasDisord() {
    return identities.some(identity => identity.provider === 'discord')
  }

  // this event is fired from the OAuth popup window
  window.addEventListener('message', function(event) {
  if (event.data == 'identity-connected') {
    router.reload()
  }
})
</script>

<section>
  <h2>Connections</h2>
  <div class="asset">
    {#each identities as identity}  
    <div class="identity">
      {identity.provider}: {identity.info.name}
    </div>
    {:else}
      No connections yet.
    {/each}
  </div>
</section>
{#if !hasDisord()}
  <section>
    <p>Connect your Discord account to unlock tokenholder benefits.</p>
    <button class="btn secondary mt-4" on:click={() => authenticate('discord')}>Connect Discord</button>
  </section>
{/if}
