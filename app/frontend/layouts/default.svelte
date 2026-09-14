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
  
  <aside>
    {#if $currentUser}
    <Frame src="/user" />
    {:else}
    <Frame src="/user/new" />
    {/if}
  </aside>
</div>


<style>
  .layout {
    display: grid;
    height: 100%;
    grid-template-rows: 1fr auto;
    grid-template-areas: 
      "main"
      "aside";
  }

  main {
    grid-area: main;
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
      grid-template-areas: 
        "main aside";
    }
    aside {
      border-top: none;
      border-left: 1px solid var(--color-border);
    }

  }
</style>

