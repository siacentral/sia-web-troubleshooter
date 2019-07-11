import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export default new Vuex.Store({
	state: {
		coinPrice: null
	},
	mutations: {
		setCoinPrice(state, price) {
			state.coinPrice = price;
		}
	},
	actions: {
		setCoinPrice(context, price) {
			context.commit('setCoinPrice', price);
		}
	}
});
