import Vue from 'vue'
import VueRouter from 'vue-router';
Vue.use(VueRouter);

import Balances from './components/balances.vue';
import NewAsset from './components/token_studio.vue';
// import Error500 from './components/errors/500.vue';
// import Error404 from './components/errors/404.vue';

const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: '/balances', component: Balances, name: 'balances' },
    { path: '/token_studio', component: NewAsset, name: 'token_studio' },
    // { path: '/500', component: Error500 },
    // { path: '/404', component: Error404 }
    // { path: '*', component: Error404 }
  ]
});

export default router;
