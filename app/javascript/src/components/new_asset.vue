<template lang="pug">
.page
  .container
    .card
      h2 Step 1: Create Contract
      form(:action="createUrl")
        table.form
          tbody
            tr.field
              th.label Name
              td.input
                input(name="name" v-model="newAsset.name")
            tr.field
              th.label Symbol
              td.input
                input(name="symbol" v-model="newAsset.symbol")
            tr.field
              th.label Decimals
              td.input
                input(name="decimals" v-model="newAsset.decimals")
            tr.field
              th.label {{ newAsset.mintable ? 'Initial Supply' : 'Total (max) Supply'}}
              td.input
                input(name="initial_supply" v-model="newAsset.initialSupply")
                label
                  input(type="checkbox" name="mintable" v-model="newAsset.mintable")
                  |  Enable minting
                  
            tr.field(v-if="newAsset.mintable")
              th.label Max supply
              td.input
                input(name="max_supply" v-model="newAsset.maxSupply")
                |  (0 for unlimited)
            tr.field
              th.label
              td.input
                label
                  input(type="checkbox" name="pausable" v-model="newAsset.pausable")
                  |  Enable pausing
            tr.field(v-if="newAsset.mintable")
              th.label
              td.input
                label
                  input(type="checkbox" name="crowdsale" v-model="newAsset.crowdsale")
                  |  Enable Crowd Sales
            tr.field(v-if="newAsset.crowdsale && newAsset.mintable")
              th.label Start Date
              td.input
                input(name="start_date" type="datetime-local" v-model="newAsset.start_date")
                |  UTC (GMT+0)
            tr.field(v-if="newAsset.crowdsale && newAsset.mintable")
              th.label Price
              td.input
                | 1 {{ newAsset.symbol }} = 
                input(name="price" v-model="newAsset.price")
                |  ETH
            tr.field(v-for="(phase, index) in newAsset.phases" v-if="newAsset.crowdsale && newAsset.mintable")
              th.label
                | Phase {{ index + 1}} 
                a(@click="newAsset.phases.splice(index, 1)") Remove phase
              td.input
                .bonus
                  | % Bonus: 
                  input(:name="`phases[]bonus`" v-model="phase.bonus")
                .end
                  | End: 
                  input(:name="`phases[]end`" type="datetime-local" v-model="phase.end")
            tr.field(v-if="newAsset.crowdsale && newAsset.mintable")
              th.label
              td.input
                label
                  button(@click.prevent="addphase") Add Phase
            tr.field(v-if="newAsset.crowdsale && newAsset.mintable")
              th.label End Date
              td.input
                input(name="end_date" type="datetime-local" v-model="newAsset.end_date")
                |  UTC (GMT+0)
        button Download Contract
  .container
    .card
      h2 Step 2: Deploy Contract
      p 
        | After downloading, open the contract in  
        a(target="_blank" href="http://remix.ethereum.org/") Remix
        |  and deploy it to the network.
  .container
    .card
      h2 Step 3: Submit Contract
      p Once you have deployed the contract on the network, please enter the details below.
      form(action="/assets" method="post")
        input(type="hidden" name="authenticity_token" :value="$store.state.authenticity_token")
        table.form
          tbody
            tr.field
              th.label Platform
              td.input
                select(name="asset[platform_id]" v-model="newAsset.platform_id")
                  option(v-for="platform in $store.state.platforms" :value="platform.id") {{ platform.name }}
              tr.field
                th.label Address
                td.input
                  input(name="asset[address]" v-model="newAsset.address")          
        button Submit


</template>


<script lang="coffee">
module.exports =
  data: ->
    newAsset:
      symbol: 'MT'
      name: 'My Token'
      decimals: '8'
      initialSupply: '10000000'
      mintable: false
      has_cap: false
      pausable: false
      maxSupply: '20000000'
      address: ''
      platform_id: 1
      crowdsale: false
      start_date: new Date()
      end_date: new Date()
      price: 1
      phases: []
  methods:
    addphase: ->
      this.newAsset.phases.push bonus: 0, start: new Date()

  computed:
    createUrl: ->
      '/assets/contract'
</script>
