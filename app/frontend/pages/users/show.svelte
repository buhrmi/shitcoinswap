<script>
  import { currentUser, balances } from "~/lib/stores"
</script>

<section>
  <p>
    Logged in as {$currentUser?.name}
  </p>
  <a href="/session" data-method="delete">Log out</a>
</section>

<section>
  <h2>Balances</h2>
  <div class="asset">
    {#each $balances as balance}  
      {balance.asset.name}: {balance.available}
      <a class="btn" href="/deposits/new?asset_id={balance.asset_id}">Deposit</a>
    {/each}
  </div>
</section>
