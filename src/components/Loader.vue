<template>
	<transition name="fade" appear>
		<div class="loader">
			<div class="loading-indicator"><font-awesome :icon="['fal', 'spinner']" /></div>
			<div class="loading-text">{{ text }}</div>
		</div>
	</transition>
</template>

<script>
export default {
	props: {
		text: String
	}
};
</script>

<style lang="stylus" scoped>
@keyframes spin {
    from {
        transform:rotate(0deg);
    }
    to {
        transform:rotate(360deg);
    }
}

.loader {
	position: fixed;
	display: grid;
	top: 0;
	bottom: 0;
	left: 0;
	right: 0;
	background: bg;
	z-index: 999;
	grid-template-rows: auto auto;
	align-content: center;
	justify-content: center;

	.loading-indicator {
		text-align: center;
		margin-bottom: 30px;

		> * {
			color: primary;
			font-size: 4rem;
			animation-name: spin;
			animation-duration: 1500ms;
			animation-iteration-count: infinite;
			animation-timing-function: linear;
		}
	}

	.loading-text {
		color: primary;
		font-size: 1.2rem;
	}
}
</style>
