<template>
	<div id="app" :class="style">
		<transition name="fade" mode="out-in" appear>
			<router-view/>
		</transition>
	</div>
</template>

<script>
import { mapState } from 'vuex';

export default {
	computed: {
		...mapState(['style'])
	},
	mounted() {
		console.log(this.style);
	}
};
</script>

<style lang="stylus">
@require "/styles/global.styl";

#app {
	width: 100%;
	height: 100%;
}

.emergency-alert {
	position: fixed;
	display: grid;
	top: 0;
	left: 0;
	right: 0;
	width: 100%;
	padding: 20px;
	grid-template-columns: 32px auto;
	grid-gap: 15px;
	align-items: center;
	justify-content: center;
	color: rgba(255, 255, 255, 0.84);
	background: #b15858;
	border-bottom: 2px solid #601919;
}
</style>
