<script>
  import { deposits } from '~/lib/stores'
  
  const {
    wallet
  } = $props()

  const walletDeposits = $derived($deposits.filter((d) => d.wallet_id == wallet.id))
</script>

<main>
  <section>
    <a href="/user">Back</a>
  </section>
  <section>
    <p>
      Deposit address:
      {wallet.address}
    </p>
  </section>
  <section>
    <div class="deposit">

      {#each walletDeposits as deposit (deposit.id)}
      Got deposit: {deposit.amount}
      {:else}
      Waiting...
      {/each}
    </div>
  </section>
</main>