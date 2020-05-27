<template>
	<div class="message-panel">
		<font-awesome :icon="['fal', icon]" v-if="icon && icon.length > 0" />
		<div class="loading-title" v-if="text && text.length > 0">{{ text }}</div>
		<div class="loading-sub" v-if="subtext && subtext.length > 0">{{ subtext }}</div>
	</div>
</template>

<script>
export default {
	props: {
		icon: String,
		text: String,
		subtext: String
	}
};
</script>

<style lang="stylus" scoped>
.message-panel {
	padding: 50px;
	text-align: center;

	> svg.svg-inline--fa {
		color: primary;
		font-size: 3rem;
		margin-bottom: 20px;
	}

	.loading-title {
		font-size: 1rem;
		color: rgba(0, 0, 0, 0.4);
	}

	.loading-sub {
		font-size: 0.8rem;
		color: rgba(0, 0, 0, 0.4);
	}
}

.scprime .message-panel > svg.svg-inline--fa {
	color: primary-scp;	
}
</style>
