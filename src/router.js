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
			path: '/:network/:address',
			name: 'check results',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckResults.vue`),
			props: (route) => {
				return {
					address: decodeURIComponent(route.params.address),
					network: route.params.network
				};
			}
		},
		{
			path: '/scprime',
			name: 'check address scprime',
			redirect: (to) => ({
				name: 'unsupported'
			})
		},
		{
			path: '/scprime/:address',
			name: 'check results scprime',
			redirect: (to) => ({
				name: 'unsupported'
			})
		},
		{
			// note: still used by SiaStats
			path: '/results/:network/:address',
			name: 'legacy redirect',
			redirect: (to) => {
				switch (to.params.network) {
				case 'scprime':
					return {
						name: 'check results scprime',
						params: {
							address: to.params.address
						}
					};
				default:
					return {
						name: 'check results',
						params: {
							network: to.params.network,
							address: to.params.address
						}
					};
				}
			}
		},
		{
			// note: still used by Host Manager
			path: '/results/:address',
			name: 'legacy redirect 2',
			redirect: (to) => {
				return {
					name: 'check results',
					params: {
						network: 'sia',
						address: to.params.address
					}
				};
			}
		},
		{
			path: '/unsupported',
			name: 'unsupported',
			component: () => import(/* webpackChunkName: "unsupported" */ `@/views/Unsupported.vue`)
		}
	]
});
