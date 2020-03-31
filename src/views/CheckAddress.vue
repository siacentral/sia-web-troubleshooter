<template>
	<div class="page">
		<div class="page-content">
			<form class="panel">
				<div class="control">
					<label>Net Address (address and port)</label>
					<input type="text" v-model="netAddress" />
				</div>
				<div class="control">
					<label>Network</label>
					<select v-model="newNetwork" @change="onChangeNetwork">
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
import { mapState, mapActions } from 'vuex';
import Logos from '@/components/Logos';

export default {
	components: {
		Logos
	},
	computed: {
		...mapState(['blockchain'])
	},
	data() {
		return {
			netAddress: '',
			newNetwork: 'sia'
		};
	},
	beforeMount() {
		this.newNetwork = this.blockchain;
	},
	methods: {
		...mapActions(['setBlockchain']),
		onSubmit() {
			this.$router.push({
				name: 'check results',
				params: {
					address: this.netAddress.toLowerCase()
				}
			});
		},
		onChangeNetwork() {
			try {
				this.setBlockchain(this.newNetwork);
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