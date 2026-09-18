<script>
  const {
    asset
  } = $props()
</script>

<svelte:head>
  <title>{asset.name} on Shitcoin Swap</title>
</svelte:head>

<main>
  <section>
    <h2>{asset.name}</h2>
    <p>{asset.description}</p>
    <p>Sign up to short</p>
  </section>
</main>