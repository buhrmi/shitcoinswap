<script>
  const {
    assets
  } = $props()

  function pathFor(asset) {
    if (!asset.contract_address || !asset.network_id) return `/assets/${asset.id}`
    return `/networks/${encodeURIComponent(asset.network_id)}/assets/${asset.contract_address}`
  }
</script>

<main>
  <section>
    <h2>What's hot right now?</h2>
    {#each assets as asset (asset.id)}
      <div class="asset">
        <a href={pathFor(asset)}>
          {asset.name}
        </a>
      </div>
    {/each}
  </section>
  <section class="w-full">
    <iframe class="aspect-video" width="100%"  src="https://www.youtube.com/embed/lFtz99Y7_nM?si=tctY57xtTCQcfSOd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
  </section>
</main>

