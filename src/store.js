import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

const params = new URLSearchParams(window.location.search.substring(1)),
	defaultBlockchain = params.get('blockchain') || localStorage.getItem('blockchain') || 'sia',
	defaultCurrency = params.get('currency') || localStorage.getItem('currency') || 'sc',
	defaultDataUnit = params.get('unit') || localStorage.getItem('unit') || 'decimal';

localStorage.setItem('blockchain', defaultBlockchain);
localStorage.setItem('currency', defaultCurrency);
localStorage.setItem('unit', defaultDataUnit);

const store = new Vuex.Store({
	state: {
		exchangeRate: null,
		blockchain: defaultBlockchain,
		currency: defaultCurrency,
		dataUnit: defaultDataUnit
	},
	mutations: {
		setBlockchain(state, chain) {
			state.blockchain = chain;
		},
		setExchangeRate(state, price) {
			state.exchangeRate = price;
		},
		setCurrency(state, currency) {
			state.currency = currency;
		},
		setDataUnit(state, dataUnit) {
			state.dataUnit = dataUnit;
		}
	},
	actions: {
		setBlockchain({ commit }, chain) {
			commit('setBlockchain', chain);
			localStorage.setItem('blockchain', chain);
		},
		setExchangeRate(context, price) {
			context.commit('setExchangeRate', price);
		},
		setCurrency(context, currency) {
			context.commit('setCurrency', currency);
			localStorage.setItem('currency', currency);
		},
		setDataUnit(context, dataUnit) {
			context.commit('setDataUnit', dataUnit);
			localStorage.setItem('unit', dataUnit);
		}
	}
});

export default store;