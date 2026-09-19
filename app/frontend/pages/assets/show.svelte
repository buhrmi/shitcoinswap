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
    <nav>
      <a href="/">
        Assets
      </a>
      &RightAngleBracket; {asset.name}
    </nav>
  </section>
  <section>
    <div class="flex gap-2">
      <img src={asset.icon.url} class="h-22 w-22 rounded-full" />
      <div class="info">
        <h2>{asset.name}</h2>
        <p>{asset.description}</p>
      </div>
    </div>
  </section>
</main>