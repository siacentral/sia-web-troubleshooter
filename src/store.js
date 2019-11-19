import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export default new Vuex.Store({
	state: {
		exchangeRate: null,
		currency: 'sc'
	},
	mutations: {
		setExchangeRate(state, price) {
			state.coinPrice = price;
		},
		setCurrency(state, currency) {
			state.currency = currency;
		}
	},
	actions: {
		setExchangeRate(context, price) {
			context.commit('setExchangeRate', price);
		},
		setCurrency(context, currency) {
			context.commit('setCurrency', currency);
		}
	}
});
