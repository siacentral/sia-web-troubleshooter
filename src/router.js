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
			path: '/sia',
			name: 'check address sia',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckAddress.vue`)
		},
		{
			path: '/sia/:address',
			name: 'check results',
			component: () => import(/* webpackChunkName: "connection-check" */ `@/views/CheckResults.vue`),
			props: (route) => {
				return {
					address: decodeURIComponent(route.params.address)
				};
			}
		},
		{
			path: '/scprime',
			name: 'check address scprime',
			component: () => import(/* webpackChunkName: "connection-check-scp" */ `@/views/CheckAddressScPrime.vue`)
		},
		{
			path: '/scprime/:address',
			name: 'check results scprime',
			component: () => import(/* webpackChunkName: "connection-check-scp" */ `@/views/CheckResultsScPrime.vue`),
			props: (route) => {
				return {
					address: decodeURIComponent(route.params.address)
				};
			}
		}
	]
});
