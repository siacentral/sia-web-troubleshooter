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
			path: '/:network/results/:address',
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
		},
		/**
		 * These endpoints remain for compatibility purposes, eventually I'd like to remove them
		 */
		{
			path: '/results/:address',
			name: 'check results compat',
			redirect: (to) => {
				const { params, query } = to;

				console.log(params, query);

				return {
					name: 'check results',
					params: {
						...params,
						network: 'sia'
					},
					query
				};
			}
		},
		{
			path: '/results/:network/:address',
			name: 'check results compat',
			redirect: (to) => {
				const { params, query } = to;

				console.log(params, query);

				return {
					name: 'check results',
					params,
					query
				};
			}
		}
	]
});
