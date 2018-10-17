<template>
  <div>
    <h1>My Balances</h1>
    
    <table>
      <tr>
        <th>Asset</th>
        <th>Balance</th>
        <th></th>
      </tr>
      <tr v-for="asset in $store.state.assets" :key="asset.id">
        <td>{{ asset.name }}</td>
        <td>{{ $store.state.balances[asset.id] && $store.state.balances[asset.id].available || 0 }}</td>
        <td>
          <a :href="`/withdrawals/new?asset_id=${asset.id}`">Withdraw</a> |
          <a :href="`/deposits/new?asset_id=${asset.id}`">Deposit</a> |
          <a :href="`/balance_adjustments?asset_id=${asset.id}`">History</a>
        </td>
      </tr>
    </table>
  </div>
</template>

<script>
export default {
  
}
</script>

