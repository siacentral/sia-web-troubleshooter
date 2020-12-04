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
			path: '/:network',
			name: 'check address locked',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckAddress.vue`),
			props: (route) => {
				let network = (route.params?.network || 'sia').toLowerCase();

				switch (network) {
				case 'sia':
				case 'scprime':
					break;
				default:
					network = 'sia';
				}
				return {
					network
				};
			}
		},
		{
			path: '/results/:address',
			name: 'check results compat',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckResults.vue`),
			props: (route) => ({
				network: 'sia',
				address: decodeURIComponent(route.params.address)
			})
		},
		{
			path: '/results/:network/:address',
			name: 'check results',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckResults.vue`),
			props: (route) => {
				let network = (route.params?.network || 'sia').toLowerCase();

				switch (network) {
				case 'sia':
				case 'scprime':
					break;
				default:
					network = 'sia';
				}
				return {
					network,
					address: decodeURIComponent(route.params.address)
				};
			}
		}
	]
});
