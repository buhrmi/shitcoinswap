<script>
  import PriceChart from "~/components/PriceChart.svelte"
  import tippy from 'tippy.js';
  import 'tippy.js/dist/tippy.css'; // optional for styling


  const {
    pair
  } = $props()
</script>

<svelte:head>
  <title>Buy {pair.base_asset.name} for {pair.quote_asset.name} on Shitcoin Swap</title>
</svelte:head>

<main>
  <section>
    <nav>
      <a href="/">
        Assets
      </a>
      &RightAngleBracket; {pair.base_asset.name}
    </nav>
  </section>
  <section>
    <div class="flex gap-2">
      <img src={pair.base_asset.icon.url} class="h-22 w-22 rounded-full" />
      <div class="details">
        <h2>{pair.base_asset.name}</h2>
        <p>{pair.base_asset.description}</p>
        <p class="shield cursor-pointer mt-2" use:tippy={{content: "This token has not yet been migrated to a network and can only be traded on Shitcoin Swap."}}>
          <span class="i-mdi:info">Info</span>
          Not on network
        </p>
      </div>
    </div>
  </section>
  <section>
    <PriceChart prices={[]} {pair} />
  </section>
</main>

<style>
  .shield {
    display: inline-flex;
    gap: 0.25rem;
    align-items:center;
    border: 1px solid var(--color-border);
    padding: 2px 9px;
    background: #222;
    border-radius: 8px;
    color: #aab;
  }
</style>