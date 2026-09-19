<script>
  import QRCode from "qrcode"
  import { deposits } from '~/lib/stores'
  
  const {
    wallet
  } = $props()

  const walletDeposits = $derived($deposits.filter((d) => d.wallet_id == wallet.id))

  let qrCode = $state()
  let copied = $state(false)

  $effect(() => {
    QRCode.toDataURL(wallet.address, { width: 512, margin: 1 })
      .then((url) => (qrCode = url))
      .catch((error) => console.error("Could not draw the address as a QR code", error))
  })

  async function copyAddress() {
    try {
      await navigator.clipboard.writeText(wallet.address)
      copied = true
      setTimeout(() => (copied = false), 1500)
    } catch (error) {
      console.error("Could not copy the address", error)
    }
  }
</script>

<main>
  <section>
    <a href="/balances">Back</a>
  </section>
  <section>
    <div class="receive">

    <p>
      Scan to deposit
    </p>
    
    {#if qrCode}
    <img class="qr" src={qrCode} alt="QR code of the deposit address" />
    {/if}
    
    <code class="address" title={wallet.address}>{wallet.address}</code>
    
    <button class="btn w-full" type="button" onclick={copyAddress}>
      {copied ? "Copied!" : "Copy address"}
    </button>
  </div>
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

<style>
  .receive {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.75rem;
    /* The section is a grid and its auto column would otherwise size to the
       address, pushing it out of the panel instead of letting it truncate. */
    min-width: 0;
  }

  .qr {
    width: 100%;
    max-width: 220px;
    height: auto;
    background: #ffffff;
    border-radius: 12px;
    padding: 8px;
  }

  .address {
    /* Show as much of the address as fits, the rest is one copy away. */
    display: block;
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    font-family: monospace;
    font-size: 14px;
  }
</style>
