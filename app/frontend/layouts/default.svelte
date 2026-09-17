<script>
  import { Frame } from 'inertiax-svelte'
  import { currentUser } from '~/lib/stores'
  
  import './default.css'

  const {
    children
  } = $props()
</script>

<svelte:head>
  <title>Shitcoin Swap</title>
</svelte:head>

<div class="layout">

  {@render children?.()}
  
<header>
  <section>
    <div class="md:flex items-center">
      <div class="grow">
        <img src="~/assets/logo.jpg" class="h-16 inline-block" alt="Shitcoin Swap Logo"/>
        <img src="~/assets/shitcoinswap.svg" class="h-12 inline-block" alt="Shitcoin Swap Logo"/>
      </div>
      <p>Delivering Quality since 1982</p>
    </div>
  </section>
</header>

  <aside>
    {#if $currentUser}
    <section>
      <p>
        Logged in as {$currentUser?.name}
      </p>
      <a href="/session" data-method="delete">Log out</a>
    </section>

    <Frame src="/user" />
    {:else}
    <Frame src="/user/new" />
    {/if}
  </aside>
  <footer>
    <section>
      <p>
        Shitcoin Swap is a
        <a href="https://github.com/buhrmi/shitcoinswap" target="_blank">
          publicly auditable
        </a>
        crypto investment platform.
      </p>
    </section>
  </footer>
</div>


<style>
  .layout {
    display: grid;
    height: 100%;
    grid-template-rows: auto 1fr auto auto;
    grid-template-areas: 
      "header"
      "main"
      "aside"
      "footer";
  }

  main {
    grid-area: main;
  }
  header {
    grid-area: header;
  }
  aside {
    grid-area: aside;
    border-top: 1px solid var(--color-border);
  }

  @media (min-width: 760px) {
    .layout {
      display: grid;
      height: 100%;
      grid-template-columns: 1fr 320px;
      grid-template-rows: auto 1fr auto;
      grid-template-areas: 
        "header aside"
        "main aside"
        "footer aside";
    }
    aside {
      border-top: none;
      border-left: 1px solid var(--color-border);
    }

  }
</style>

