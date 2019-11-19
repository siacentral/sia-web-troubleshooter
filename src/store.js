import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

const store = new Vuex.Store({
	state: {
		exchangeRate: null,
		currency: localStorage.getItem('currency') || 'sc',
		dataUnit: localStorage.getItem('unit') || 'binary'
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