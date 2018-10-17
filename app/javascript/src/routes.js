import Vue from 'vue'
import VueRouter from 'vue-router';
Vue.use(VueRouter);

import Home from './components/home.vue';
import Balances from './components/balances.vue';
import NewAsset from './components/new_asset.vue';
import Error500 from './components/errors/500.vue';
import Error404 from './components/errors/404.vue';

const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: Home, name: 'root_path' },
    { path: '/balances', component: Balances, name: 'balances_path' },
    { path: '/assets/new', component: NewAsset, name: 'new_asset_path' },
    { path: '/500', component: Error500 },
    { path: '/404', component: Error404 },
    { path: '*', component: Error404 }
  ]
});

export default router;