<script>
  const {
    pair
  } = $props()

</script>

<div class="card">
  <a href="/pairs/{pair.id}" class="flex gap-2 items-center p-4">
    <img src={pair.base_asset.icon.url} class="h-12 w-12 rounded-full "/>
    {pair.base_asset.name}
  </a>
</div>
