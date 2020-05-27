<template>
	<div class="page">
		<div class="page-content">
			<form class="panel">
				<div class="control">
					<label>Net Address (address and port)</label>
					<input type="text" v-model="netAddress" @change="onChangeNetAdress" />
				</div>
				<div class="control">
					<label>Network</label>
					<select v-model="network" @change="onChangeNetwork">
						<option value="sia">Sia</option>
						<option value="scprime">SCPrime</option>
					</select>
				</div>
				<div class="button-wrapper">
					<button class="btn btn-success btn-inline" @click.prevent="onSubmit">Check My Host</button>
				</div>
			</form>
			<logos />
		</div>
	</div>
</template>

<script>
import { mapActions } from 'vuex';
import Logos from '@/components/Logos';

export default {
	components: {
		Logos
	},
	data() {
		return {
			network: 'sia',
			netAddress: ''
		};
	},
	beforeMount() {
		this.netAddress = localStorage.getItem('lastAddress') || '';
		this.network = localStorage.getItem('network') || 'sia';
		this.setStyle(this.network);
	},
	methods: {
		...mapActions(['setStyle']),
		onSubmit() {
			this.$router.push({
				name: 'check results',
				params: {
					address: this.netAddress.toLowerCase(),
					network: this.network
				}
			});
		},
		onChangeNetwork() {
			try {
				localStorage.setItem('network', this.network);
				this.setStyle(this.network);
			} catch (ex) {
				console.error('CheckAddress.onChangeNetwork', ex);
			}
		},
		onChangeNetAdress() {
			try {
				localStorage.setItem('lastAddress', this.netAddress);
			} catch (ex) {
				console.error('CheckAddress.onChangeNetwork', ex);
			}
		}
	}
};
</script>

<style lang="stylus" scoped>
.page-content {
	display: grid;
	width: 100%;
	height: 100%;
	margin: auto;
	grid-template-rows: minmax(0, 1fr) auto;
	align-items: center;
	max-width: 500px;
}

.button-wrapper {
	text-align: center;
}
</style>