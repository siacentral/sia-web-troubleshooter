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
			this.$emit('check', this.netAddress);
		}
	}
};
</script>

<style lang="stylus" scoped>
.page-content {
	grid-template-columns: 1fr;
}

@media screen and (min-width: 500px) {
	.page-content {
		grid-template-columns: 60vw;
	}
}

@media screen and (min-width: 1200px) {
	.page-content {
		grid-template-columns: 30vw;
	}
}

.button-wrapper {
	text-align: center;
}
</style>
