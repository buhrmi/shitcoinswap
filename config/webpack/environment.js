const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')
const pug =  require('./loaders/pug')
const vue =  require('./loaders/vue')

environment.loaders.append('vue', vue)
environment.loaders.append('coffee', coffee)
environment.loaders.append('pug', pug)

const VueLoaderPlugin = require('vue-loader/lib/plugin')
environment.plugins.append(
  'VueLoaderPlugin',
  new VueLoaderPlugin()
)

module.exports = environment
