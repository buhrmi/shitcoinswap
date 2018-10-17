const { environment } = require('@rails/webpacker')
const coffee =  require('./loaders/coffee')
const pug =  require('./loaders/pug')
const vue =  require('./loaders/vue')

environment.loaders.append('vue', vue)
environment.loaders.append('coffee', coffee)
environment.loaders.append('pug', pug)
module.exports = environment
