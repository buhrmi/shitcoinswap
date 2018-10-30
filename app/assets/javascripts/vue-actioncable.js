var cable = ActionCable.createConsumer()

var plugin = {
  install: function(Vue, cable) {
    Vue.mixin({
      destroyed: function() {
        if (!this._subscriptions) return
        Object.keys(this._subscriptions).map(function(key) {
          this._subscriptions[key].unsubscribe()
        })
      },
      mounted: function() {
        this.$cable = cable
        var subscriptionsOptions = this.$options.subscriptions
        if (!subscriptionsOptions) return
        this._subscriptions = {}
        if (typeof subscriptionsOptions == 'function') subscriptionsOptions = subscriptionsOptions()
        Object.keys(subscriptionsOptions).map(function(channelName) {
          var subOptions = subscriptionsOptions[channelName]
          if (!subOptions.params) subOptions.params = {}
          var paramsFn = subOptions.params
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