<template>
	<transition name="fade" appear>
		<div class="modal">
			<a href="#" class="close" @click.prevent="onClose"><font-awesome :icon="['fal', 'times']" /></a>
			<div class="modal-content">
				<slot></slot>
			</div>
		</div>
	</transition>
</template>

<script>
export default {
	methods: {
		onClose() {
			this.$emit('close');
		}
	}
};
</script>

<style lang="stylus" scoped>
.modal {
	position: fixed;
	margin: auto;
	top: 0;
	left: 0;
	bottom: 0;
	right: 0;
	background: #ffffff;
	border-radius: 8px;
	box-shadow: 0 5px 10px rgba(0, 0, 0, 0.1);
	overflow: hidden;
	z-index: 999;

	.modal-content {
		max-width: 800px;
		height: 100%;
		overflow-x: hidden;
		overflow-y: auto;
		padding: 30px;
		margin: auto;
	}

	> a.close {
		position: absolute;
		top: 15px;
		right: 15px;
		color: rgba(0, 0, 0, 0.54);
		text-decoration: none;
		outline: none;
	}
}
</style>
