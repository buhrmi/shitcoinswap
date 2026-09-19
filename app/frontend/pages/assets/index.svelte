<script>
  import AssetCard from '~/components/AssetCard.svelte'
  const {
    assets
  } = $props();
</script>

<main>
<section>
  <div class="card-list">
    {#each assets as asset}
      <div class="card">
        <AssetCard {asset}/>
      </div>
    {/each}
  </div>
</section>
  <section class="w-full">
    <iframe class="aspect-video" width="100%"  src="https://www.youtube.com/embed/lFtz99Y7_nM?si=tctY57xtTCQcfSOd" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
  </section>
</main>

<style>

</style>