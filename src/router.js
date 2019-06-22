import Vue from 'vue';
import Router from 'vue-router';
import CheckAddress from './views/CheckAddress.vue';
import CheckResults from './views/CheckResults.vue';

Vue.use(Router);

export default new Router({
	mode: 'history',
	base: process.env.BASE_URL,
	routes: [
		{
			path: '/',
			name: 'check address',
			component: CheckAddress
		},
		{
			path: '/results/:address',
			name: 'check results',
			component: CheckResults,
			props: true
		}
	]
});
