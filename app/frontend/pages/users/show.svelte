<script>
  import { balances } from "~/lib/stores"
</script>

<section>
  <h2>Balances</h2>
  <div class="asset">
    {#each $balances as balance}  
      {balance.asset.name}: {balance.available}
      <a class="btn" href="/deposits/new?asset_id={balance.asset_id}">Deposit</a>
    {/each}
  </div>
</section>
