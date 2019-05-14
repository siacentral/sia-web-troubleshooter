<template>
	<transition name="fade" appear>
		<enter-address-form v-if="step === 0" @check="onCheck" />
		<check-host v-if="step === 1" :address="netAddress" />
	</transition>
</template>

<script>
import EnterAddressForm from '@/components/EnterAddressForm';
import CheckHost from '@/components/CheckHost';

export default {
	name: 'home',
	components: {
		EnterAddressForm,
		CheckHost
	},
	data() {
		return {
			step: 0,
			netAddress: null
		};
	},
	methods: {
		onCheck(address) {
			try {
				console.log(address);

				if (address.split(':').length < 2)
					return;

				this.step++;
				this.netAddress = address;
			} catch (ex) {
				console.log(ex);
			}
		}
	}
};
</script>

<style lang="stylus" scoped>

</style>