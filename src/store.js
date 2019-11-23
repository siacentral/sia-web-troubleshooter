import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

const params = new URLSearchParams(window.location.search.substring(1)),
	defaultCurrency = params.get('currency') || localStorage.getItem('currency') || 'sc',
	defaultDataUnit = params.get('unit') || localStorage.getItem('unit') || 'decimal';

localStorage.setItem('currency', defaultCurrency);
localStorage.setItem('unit', defaultDataUnit);

const store = new Vuex.Store({
	state: {
		exchangeRate: null,
		currency: defaultCurrency,
		dataUnit: defaultDataUnit
	},
	mutations: {
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