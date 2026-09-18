<script>
  const {
    asset
  } = $props()

  function pathFor(asset) {
    if (!asset.contract_address || !asset.network_id) return `/assets/${asset.id}`
    return `/networks/${encodeURIComponent(asset.network_id)}/assets/${asset.contract_address}`
  }
</script>

<div class="card">
  <a href={pathFor(asset)}>
    {asset.name}
  </a>
</div>
