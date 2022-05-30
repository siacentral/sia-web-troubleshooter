<template>
	<div class="error-alert">
		<h3>Error - not found</h3>
		<router-link to="/" class="btn btn-success btn-inline">Back</router-link>
	</div>
</template>

<style lang="stylus" scoped>
	.error-alert {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		height: 100%;
		width: 100%;
		font-size: 1.5em;
		text-align: center;
	}

	a {
		text-decoration: none;
	}
</style>