<script>
  import PriceChart from "~/components/PriceChart.svelte"

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
      <div class="info">
        <h2>{pair.base_asset.name}</h2>
        <p>{pair.base_asset.description}</p>
      </div>
    </div>
  </section>
  <section>
    <PriceChart prices={[]} {pair} />
  </section>
</main>