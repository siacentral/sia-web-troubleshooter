import Vue from 'vue';
import App from './App';
import router from './router';
import store from './store';

import { library } from '@fortawesome/fontawesome-svg-core';
import { faUser, faBell, faHdd, faDownload, faRedo, faFileContract, faCogs, faFolder, faTerminal, faLock, faDollarSign, faWallet, faServer } from '@fortawesome/pro-light-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

library.add(faUser, faBell, faHdd, faDownload, faRedo, faFileContract, faCogs, faFolder, faTerminal, faLock, faDollarSign, faWallet, faServer);

Vue.component('font-awesome', FontAwesomeIcon);

Vue.config.productionTip = false;

/* eslint-disable no-new */
new Vue({
	router,
	store,
	render: h => h(App)
}).$mount('#app');
