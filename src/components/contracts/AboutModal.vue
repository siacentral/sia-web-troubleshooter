<template>
	<modal @close="onClose">
		<h2>SiaCentral Contract Utility</h2>
		<p>This utility gives hosts access to more statistics and information about the health of their hosts
			without having to install anything. By parsing the contracts stored locally on the host and
			combining it with information from the block chain we can present additional metrics and
			display issues with contracts.</p>
		<p>This utility runs a few "sanity" checks to make sure all of a host's contracts are correctly represented
			within Sia. It will show errors if a contract is listed as "ongoing" but should have
			failed or completed successfully or if a proof was not submitted within the contract's proof window.</p>
		<h2>How To Use</h2>
		<p>First a host needs to obtain a list of all storage contracts currently being tracked by the host</p>
		<div class="use-section">
			<h3>With Sia Daemon</h3>
			<p>1. Open a command prompt, terminal, or bash depending on your operating system</p>
			<p>2. Run the following command <i>siac host contracts > contracts.txt</i></p>
			<p>3. Upload the file to the utility</p>
			<img src="../../assets/upload-contracts.png" alt="SiaCentral Contract Troubleshooter Screenshot" />
		</div>
		<div class="use-section">
			<h3>With Sia-UI</h3>
			<p>1. Open Sia-UI's terminal</p>
			<p>2. In the bottom box type <i>host contracts</i></p>
			<p>3. Copy all of the output</p>
			<img src="../../assets/sia-ui-contracts.png" alt="Sia-UI contracts output" />
			<p>4. Paste the output into the utility</p>
			<img src="../../assets/paste-contracts.png" alt="SiaCentral Contract Troubleshooter Screenshot" />
		</div>
	</modal>
</template>

<script>
import Modal from '@/components/Modal';

export default {
	components: {
		Modal
	},
	methods: {
		onClose() {
			this.$emit('close');
		}
	}
};
</script>

<style lang="stylus" scoped>
h2, h3, h4 {
	color: primary;
	font-weight: normal;
	text-align: center;
	margin-top: 0;
}

h3, h4 {
	text-align: left;
}

.use-section {
	padding: 15px;
	border-radius: 8px;
	background: #f5f5f5;
	margin-bottom: 15px;
}

img {
	max-width: 100%;
	padding: 10px;
}
</style>
