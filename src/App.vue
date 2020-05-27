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
</style>
