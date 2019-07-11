<template>
	<transition name="fade" appear>
		<div>
			<div class="step-title" v-if="title">{{ title }}</div>
			<div :class="{ 'panel': true,  'icon-panel': (icon && icon.length > 0) }">
				<div v-if="icon" :class="{ 'panel-icon': true, 'icon-error': error }">
					<font-awesome :icon="['fal', icon]" />
				</div>
				<div class="panel-content">
					<slot />
				</div>
			</div>
			<div class="panel-extras" v-if="extras && extras.length > 0">
				<template v-for="extra in extras">
					<div :key="`key-${extra.key || extra.value}`" class="extra-key">{{ extra.key }}</div>
					<div :key="`value-${extra.key || extra.value}`" class="extra-value">{{ extra.value }}</div>
				</template>
			</div>
		</div>
	</transition>
</template>

<script>
export default {
	props: {
		title: String,
		icon: String,
		error: Boolean,
		extras: Array
	}
};
</script>

<style lang="stylus" scoped>
.panel {
	height: 100%;
}

.step-title {
	font-size: 1.2rem;
	color: rgba(0, 0, 0, 0.4);
	margin-bottom: 15px;
}

.panel-extras {
	position: relative;
	top: -10px;
	z-index: -1;
	display: grid;
	padding: 25px 15px 15px;
	grid-template-columns: auto minmax(0, 1fr);
	grid-gap: 15px;
	background: light-gray;
    border-bottom-left-radius: 8px;
    border-bottom-right-radius: 8px;
	box-shadow: 0 2px 3px 1px rgba(0, 0, 0, 0.1);
	font-size: 0.9rem;
	color: rgba(0, 0, 0, 0.54);
}

.extra-value {
	width: 100%;
	overflow-x: auto;
}
</style>
