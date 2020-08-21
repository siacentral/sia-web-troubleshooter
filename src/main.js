import Vue from 'vue';
import App from './App';
import router from './router';
import store from './store';

import { library } from '@fortawesome/fontawesome-svg-core';
import { faTachometerAltSlowest, faTachometerAltSlow, faTachometerAltAverage, faTachometerAltFast, faTachometerAltFastest, faSync, faExclamationCircle, faTimes, faSmileBeam, faCodeBranch, faSpinner, faSearch, faDatabase, faWifi, faExclamationTriangle, faWrench, faLayerGroup, faUpload, faUnlock, faClock, faBoxOpen, faBoxFull, faLink, faFileCheck, faCloudDownload, faCloudUpload, faUser, faBell, faHdd, faDownload, faRedo, faFileContract, faCogs, faFolder, faTerminal, faLock, faDollarSign, faWallet, faServer } from '@fortawesome/pro-duotone-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

library.add(faTachometerAltSlowest, faTachometerAltSlow, faTachometerAltAverage, faTachometerAltFast, faTachometerAltFastest, faSync, faExclamationCircle, faTimes, faSmileBeam, faCodeBranch, faSpinner, faSearch, faDatabase, faWifi, faExclamationTriangle, faWrench, faLayerGroup, faUpload, faUnlock, faClock, faBoxOpen, faBoxFull, faLink, faFileCheck, faCloudDownload, faCloudUpload, faUser, faBell, faHdd, faDownload, faRedo, faFileContract, faCogs, faFolder, faTerminal, faLock, faDollarSign, faWallet, faServer);

Vue.component('font-awesome', FontAwesomeIcon);

Vue.config.productionTip = false;

/* eslint-disable no-new */
new Vue({
	router,
	store,
	render: h => h(App)
}).$mount('#app');
