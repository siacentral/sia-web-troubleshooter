<template>
	<div class="page">
		<div class="page-content">
			<form class="panel">
				<div class="control">
					<label>Net Address (address and port)</label>
					<input type="text" v-model="netAddress" />
				</div>
				<div class="button-wrapper">
					<button class="btn btn-success btn-inline" @click.prevent="onSubmit">Check My Host</button>
				</div>
			</form>
			<div>
				<a href="https://sia.tech" class="built-with"><img src="@/assets/built-with-sia.svg" /></a>
			</div>
		</div>
	</div>
</template>

<script>
export default {
	data() {
		return {
			netAddress: ''
		};
	},
	methods: {
		onSubmit() {
			this.$router.push({
				name: 'check results',
				params: {
					address: this.netAddress.toLowerCase()
				}
			});
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