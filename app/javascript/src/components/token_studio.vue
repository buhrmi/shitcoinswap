<template lang="pug">
.page
  .container
    .card.mb-3
      .card-body
        h5.card-title Step 1: Create Contract
        form(:action="createUrl")
          
          .row.form-group
            label.col-sm-2.col-form-label Name
            .col-sm-10
              input.form-control(name="name" v-model="newAsset.name")
          .row.form-group
            label.col-sm-2.col-form-label Symbol
            .col-sm-10
              input.form-control(name="symbol" v-model="newAsset.symbol")
          .row.form-group
            label.col-sm-2.col-form-label Decimals
            .col-sm-10
              input.form-control(name="decimals" v-model="newAsset.decimals")
          .row.form-group
            label.col-sm-2.col-form-label {{ newAsset.mintable ? 'Initial Supply' : 'Total Supply'}}
            .col-sm-10
              input.form-control(name="initial_supply" v-model="newAsset.initialSupply")
          .row.form-group
            .col-sm-2
            .col-sm-10
              .form-check
                input#mintable.form-check-input(type="checkbox" name="mintable" v-model="newAsset.mintable")
                label.form-check-label(for="mintable") Enable option to mint new tokens
                
          .row.form-group(v-if="newAsset.mintable")
            label.col-sm-2.col-form-label Max supply
            .col-sm-10
              input.form-control(name="max_supply" v-model="newAsset.maxSupply")
              |  (0 for unlimited)
          .row.form-group
            .col-sm-2
            .col-sm-10
              .form-check
                input#pausable.form-check-input(type="checkbox" name="pausable" v-model="newAsset.pausable")
                label.form-check-label(for="pausable") Enable option to suspend trading
          .row.form-group(v-if="newAsset.mintable")
            .col-sm-2
            .col-sm-10
              .form-check
                input#crowdsales.form-check-input(type="checkbox" name="crowdsale" v-model="newAsset.crowdsale")
                label.form-check-label(for="crowdsales") Enable Crowd Sales
          .row.form-group(v-if="newAsset.crowdsale && newAsset.mintable")
            label.col-sm-2.col-form-label Price
            .col-sm-10
              .input-group
                .input-group-prepend
                  .input-group-text 1 {{ newAsset.symbol }} =
                input.form-control(name="price" v-model="newAsset.price")
                .input-group-append
                  .input-group-text ETH
          .row.form-group(v-if="newAsset.crowdsale && newAsset.mintable")
            label.col-sm-2.col-form-label Start Date
            .col-sm-10
              .input-group
                input.form-control(name="start_date" type="datetime-local" v-model="newAsset.start_date")
                .input-group-append
                  .input-group-text UTC (GMT+0)
          .row.form-group(v-for="(phase, index) in newAsset.phases" v-if="newAsset.crowdsale && newAsset.mintable")
            .col-sm-2 Phase {{ index + 1 }} 
              a(@click="newAsset.phases.splice(index, 1)") Remove phase
            .col-sm-10
              .input-group.mb-3
                .input-group-prepend
                  .input-group-text Bonus:
                input.form-control(:name="`phases[]bonus`" v-model="phase.bonus")
                .input-group-append
                  .input-group-text %
              .input-group
                .input-group-prepend
                  .input-group-text End Date:
                input.form-control(:name="`phases[]end`" type="datetime-local" v-model="phase.end")
          .row.form-group(v-if="newAsset.crowdsale && newAsset.mintable")
            label.col-sm-2.col-form-label
            .col-sm-10
              label
                button.btn-sm(@click.prevent="addphase") Add Bonus Phase
          .row.form-group(v-if="newAsset.crowdsale && newAsset.mintable")
            label.col-sm-2.col-form-label End Date
            .col-sm-10
              .input-group
                input.form-control(name="end_date" type="datetime-local" v-model="newAsset.end_date")
                .input-group-append
                  .input-group-text UTC (GMT+0)
                
          button.btn.btn-primary Download Contract
  .container
    .card.mb-3
      .card-body
        h5.card-title Step 2: Deploy Contract
        p.card-text
          | After downloading, open the contract in  
          a(target="_blank" href="http://remix.ethereum.org/") Remix
          |  and deploy it to the network.
  .container
    .card.mb-3
      .card-body
        h5.card-title Step 3: Submit Deployment Details
        p.card-text 
          | Please submit the contract on our 
          a(href="/assets/new") contract submission page
          | .
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
