<template>
	<div class="page-content paste-or-upload">
		<div class="page-title">
			<div class="title">
				Check Host Contracts
			</div>
			<div class="links">
				<button @click="openModal = 'about'">How To Use</button>
			</div>
		</div>
		<div class="error">
			{{ error }}
		</div>
		<div class="panel">
			<label>Upload Sia contract output</label>
			<div class="upload-section" @dragstart.stop="onDropFile">
				<label :for="uploadLabel" ref="uploadButton"><font-awesome :icon="['fal', 'cloud-upload']" /> Click or Drag to Upload</label>
				<input :id="uploadLabel" type="file" name="contracts" @change="onFileSelected" ref="upload" accept=".json,application/json,.txt,text" />
			</div>
		</div>
		<div class="or-sub">
			Or
		</div>
		<div class="panel contract-paste">
			<label>Paste Sia contract output</label>
			<textarea resize="none" v-model="contractOutput"></textarea>
			<div class="buttons">
				<button class="btn btn-success btn-inline" @click="onFixContracts(contractOutput)" :disabled="contractOutput.length === 0">Check Contracts</button>
			</div>
		</div>
		<about-modal v-if="openModal === 'about'" @close="onClose" />
	</div>
</template>

<script>
import AboutModal from '@/components/contracts/AboutModal';

import { fixContracts } from '@/utils/contracts';

export default {
	components: {
		AboutModal
	},
	data() {
		return {
			contractOutput: '',
			openModal: null,
			error: null
		};
	},
	computed: {
		uploadLabel() {
			return `${this._uid}-upload-file`;
		}
	},
	methods: {
		onClose() {
			try {
				this.openModal = null;
			} catch (ex) {
				console.log(ex);
			}
		},
		onDropFile(e) {
			try {
				console.log('DRAG', e);
			} catch (ex) {
				console.log(ex);
			}
		},
		onFileSelected() {
			try {
				const reader = new FileReader();

				reader.onload = (e) => {
					this.onFixContracts(e.target.result);
				};

				reader.readAsText(this.$refs.upload.files[0]);
			} catch (ex) {
				console.log(ex);
			}
		},
		async onFixContracts(contracts) {
			try {
				this.error = null;
				console.log(contracts.length);
				this.$emit('parsing');

				const parsed = await fixContracts(contracts);

				console.log(parsed);

				this.$emit('parsed', parsed);
			} catch (ex) {
				console.log(ex);
				this.$emit('failed');
				this.error = ex.toString();
			}
		}
	}
};
</script>

<style lang="stylus" scoped>
.upload-section {
	display: flex;
	align-items: center;
	justify-content: center;
	margin-top: 15px;

	input[type="file"] {
		display: none;
	}

	label {
		display: block;
		width: 100%;
		height: 100%;
		text-align: center;
		border: 1px solid primary;
		border-radius: 8px;
		user-select: none;
		cursor: pointer;
	}
}

@media screen and (min-height: 300px) {
	.upload-section label {
		height: 100px;
		line-height: 100px;
		white-space: nowrap;
	}
}

.page-content.paste-or-upload {
	padding: 30px;
	grid-template-rows: auto auto auto auto 1fr;
    height: 100%;
    max-width: 800px;
	justify-content: initial;

	.error {
		color: negative-accent;
	}

	.panel {
		height: 100%;

		label {
			color: primary;
			font-size: 0.9rem;
		}
	}

	.panel.contract-paste {
		display: grid;
		grid-template-rows: auto 1fr auto;
		grid-gap: 15px;

		textarea {
			height: 100%;
			max-height: 100%;
			border: 1px solid light-gray;
			border-radius: 8px;
			padding: 15px;
			outline: none;
			resize: none;
			white-space: nowrap;
		}
	}
}

.page-title {
	display: grid;
	grid-template-columns: 1fr auto;
	align-items: center;
	margin: 0;
	color: rgba(0, 0, 0, 0.4);

	.links button {
		display: inline-block;
		padding: 8px 10px;
		font-size: 0.8rem;
		background: none;
		border: none;
		outline: none;
		color: primary;
		cursor: pointer;
	}
}

.or-sub {
	color: rgba(0, 0, 0, 0.54);
	text-align: center;
}

.buttons {
	text-align: center;
}
</style>
