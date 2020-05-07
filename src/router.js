import Vue from 'vue';
import Router from 'vue-router';

Vue.use(Router);

export default new Router({
	mode: 'history',
	base: process.env.BASE_URL,
	routes: [
		{
			path: '/',
			name: 'check address',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckAddress.vue`)
		},
		{
			path: '/results/:network/:address',
			name: 'check results',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckResults.vue`),
			props: true
		}
	]
});
