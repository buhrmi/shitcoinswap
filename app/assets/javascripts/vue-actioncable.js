const cable = ActionCable.createConsumer()

const plugin = {
  install(Vue, cable) {
    Vue.mixin({
      destroyed() {
        if (!this._subscriptions) return
        Object.keys(this._subscriptions).map((key) => {
          this._subscriptions[key].unsubscribe()
        })
      },
      mounted() {
        this.$cable = cable
        let subscriptionsOptions = this.$options.subscriptions
        if (!subscriptionsOptions) return
        this._subscriptions = {}
        if (typeof subscriptionsOptions == 'function') subscriptionsOptions = subscriptionsOptions()
        Object.keys(subscriptionsOptions).map((channelName) => {
          let subOptions = subscriptionsOptions[channelName]
          if (!subOptions.params) subOptions.params = {}
          let paramsFn = subOptions.params
          if (typeof paramsFn !== 'function') {
            paramsFn = function() { return subOptions.params }
          }
          this.$watch(paramsFn, function(params) {
            if (this._subscriptions[channelName]) this._subscriptions[channelName].unsubscribe()
            params.channel = channelName
            this._subscriptions[channelName] = this.$cable.subscriptions.create(params, {
              received: subOptions.received.bind(this)
            })
          }, {
            immediate: true
          })
        })
      }
    })
  }
}

Vue.use(plugin, cable)