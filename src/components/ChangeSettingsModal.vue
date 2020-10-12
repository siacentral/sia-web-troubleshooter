<template>
	<div class="modal-wrapper" @click.self="$emit('close')">
		<transition name="fade" appear>
			<div class="modal">
				<div class="control">
					<label>Display Currency</label>
					<select v-model="newCurrency">
						<optgroup label="Fiat">
							<option value="usd">USD</option>
							<option value="jpy">JPY</option>
							<option value="eur">EUR</option>
							<option value="gbp">GBP</option>
							<option value="aus">AUS</option>
							<option value="cad">CAD</option>
							<option value="rub">RUB</option>
							<option value="cny">CNY</option>
						</optgroup>
						<optgroup label="Crypto">
							<option value="btc">BTC</option>
							<option value="bch">BCH</option>
							<option value="eth">ETH</option>
							<option value="xrp">XRP</option>
							<option value="ltc">LTC</option>
						</optgroup>
					</select>
				</div>
				<div class="control">
					<label>Data Unit</label>
					<select v-model="newUnit">
						<option value="binary">Binary (1024 GiB = 1 TiB)</option>
						<option value="decimal">Decimal (1000 GB = 1 TB)</option>
					</select>
				</div>
				<div class="buttons">
					<button class="btn btn-inline btn-success" @click="$emit('close')">Done</button>
				</div>
			</div>
		</transition>
	</div>
</template>

<script>
import { mapState, mapActions } from 'vuex';

export default {
	computed: {
		...mapState(['currency', 'dataUnit'])
	},
	data() {
		return {
			newCurrency: 'usd',
			newUnit: 'decimal'
		};
	},
	beforeMount() {
		this.newCurrency = this.currency || 'usd';
		this.newUnit = this.dataUnit || 'decimal';
	},
	methods: {
		...mapActions(['setCurrency', 'setDataUnit'])
	},
	watch: {
		newCurrency() {
			this.setCurrency(this.newCurrency);
		},
		newUnit() {
			this.setDataUnit(this.newUnit);
		}
	}
};
</script>

<style lang="stylus" scoped>
.modal-wrapper {
	position: fixed;
	display: grid;
	top: 0;
	left: 0;
	bottom: 0;
	right: 0;
	background: rgba(0, 0, 0, 0.24);
	z-index: 999;
	align-content: safe center;
	justify-content: center;
}

.modal {
	padding: 15px;
	background: bg-accent;
	border-radius: 8px;
	box-shadow: 0px 1px 5px 0px rgba(0, 0, 0, 0.84);
}

select {
	min-width: 280px;
}

.buttons {
	text-align: center;

	.btn-success {
		color: rgba(0, 0, 0, 0.54);
		padding: 8px 13px;
	}

	*:last-child {
		margin-right: 0;
	}
}
</style>