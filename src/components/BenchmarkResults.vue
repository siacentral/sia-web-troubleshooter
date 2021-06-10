<template>
	<div class="host-benchmark">
		<div class="warning" v-if="showUnbenchmarkedWarning">Benchmark data is not available for hosts less than 48 hours old.</div>
		<div :class="uploadClass">
			<h3>Upload Speed</h3>
			<font-awesome :icon="['fad', uploadTachIcon]" />
			<div class="speed" v-html="uploadSpeedStr" />
			<div class="average-speed" v-html="avgUploadSpeedStr" />
		</div>
		<div :class="downloadClass">
			<h3>Download Speed</h3>
			<font-awesome :icon="['fad', downloadTachIcon]" />
			<div class="speed" v-html="downloadSpeedStr" />
			<div class="average-speed" v-html="avgDownloadSpeedStr" />
		</div>
	</div>
</template>

<script>
import { formatBitSpeed } from '@/utils/format';
import { mapState } from 'vuex';

export default {
	props: {
		benchmark: Object,
		average: Object
	},
	computed: {
		...mapState(['dataUnit']),
		showUnbenchmarkedWarning() {
			return !this.benchmark || !this.benchmark['last_attempt'] || this.benchmark['last_attempt'] === '0001-01-01T00:00:00Z';
		},
		uploadSpeed() {
			const dataSize = this.benchmark && this.benchmark.data_size ? this.benchmark.data_size : 0,
				time = this.benchmark && this.benchmark.upload_time ? this.benchmark.upload_time / 1000 : 1;

			return dataSize * 8 / time;
		},
		downloadSpeed() {
			const dataSize = this.benchmark && this.benchmark.data_size ? this.benchmark.data_size : 0,
				time = this.benchmark && this.benchmark.download_time ? this.benchmark.download_time / 1000 : 1;

			return dataSize * 8 / time;
		},
		avgUploadSpeed() {
			const dataSize = this.average && this.average.data_size ? this.average.data_size : 0,
				time = this.average && this.average.upload_time ? this.average.upload_time / 1000 : 1;

			return dataSize * 8 / time;
		},
		avgDownloadSpeed() {
			const dataSize = this.average && this.average.data_size ? this.average.data_size : 0,
				time = this.average && this.average.download_time ? this.average.download_time / 1000 : 1;

			return dataSize * 8 / time;
		},
		uploadSpeedStr() {
			const format = formatBitSpeed(this.uploadSpeed, this.dataUnit, 2);

			return `${format.value} <span class="display-currency">${format.label}</span>`;
		},
		downloadSpeedStr() {
			const format = formatBitSpeed(this.downloadSpeed, this.dataUnit, 2);

			return `${format.value} <span class="display-currency">${format.label}</span>`;
		},
		avgUploadSpeedStr() {
			const format = formatBitSpeed(this.avgUploadSpeed, this.dataUnit, 2);

			return `(Average ${format.value} <span class="display-currency">${format.label}</span>)`;
		},
		avgDownloadSpeedStr() {
			const format = formatBitSpeed(this.avgDownloadSpeed, this.dataUnit, 2);

			return `(Average ${format.value} <span class="display-currency">${format.label}</span>)`;
		},
		uploadClass() {
			const delta = this.uploadSpeed / this.avgUploadSpeed;
			let c = { 'upload': true };

			if (this.showUnbenchmarkedWarning)
				c['hidden'] = true;

			c[`upload-${this.normalizeSpeedDelta(delta)}`] = true;

			return c;
		},
		downloadClass() {
			const delta = this.downloadSpeed / this.avgDownloadSpeed;
			let c = { 'download': true };

			if (this.showUnbenchmarkedWarning)
				c['hidden'] = true;

			c[`download-${this.normalizeSpeedDelta(delta)}`] = true;

			return c;
		},
		uploadTachIcon() {
			const delta = this.uploadSpeed / this.avgUploadSpeed;

			return `tachometer-alt-${this.normalizeSpeedDelta(delta)}`;
		},
		downloadTachIcon() {
			const delta = this.downloadSpeed / this.avgDownloadSpeed;

			return `tachometer-alt-${this.normalizeSpeedDelta(delta)}`;
		}
	},
	methods: {
		normalizeSpeedDelta(d) {
			if (d <= 0.5)
				return 'slowest';
			else if (d <= 0.8)
				return 'slow';
			else if (d <= 1 || d <= 1.5)
				return 'average';
			else if (d <= 2)
				return 'fast';

			return 'fastest';
		}
	}
};
</script>

<style lang="stylus" scoped>
.host-benchmark {
	position: relative;
	display: grid;
	align-items: center;
	grid-gap: 15px;
	min-height: 200px;

	.warning {
		position: absolute;
		top: 50%;
		left: 50%;
		width: 100%;
		padding: 15px;
		background: #25272a;
		border-radius: 4px;
		transform: translate(-50%, -50%);
		box-shadow: 0 10px 20px rgba(0,0,0,0.19), 0 6px 6px rgba(0,0,0,0.23);
		z-index: 999;
	}

	@media screen and (min-width: 767px) {
		grid-template-columns: repeat(2, minmax(0, 1fr));

		.warning {
			width: auto;
			max-width: 70%;
		}
	}
}

h3 {
	text-align: center;
	margin: 0 0 5px;
	color: rgba(255, 255, 255, 0.54);
}

.upload, .download {
	&.hidden {
		opacity: 0.54;
	}

	svg {
		display: block;
		width: 40%;
		height: auto;
		margin: 0 auto 15px;
	}

	.fa-primary {
		fill: primary;
	}

	.fa-secondary {
		fill: dark-gray;
	}

	&.download-average .fa-primary, &.download-slow .fa-primary, &.upload-average .fa-primary, &.upload-slow .fa-primary {
		fill: warning-accent;
	}

	&.download-slowest .fa-primary, &.upload-slowest .fa-primary {
		fill: negative-accent;
	}
}

.speed, .average-speed {
	text-align: center;
}

.speed {
	font-size: 1.5rem;
	margin-bottom: 2px;
}

.average-speed {
	font-size: 0.8rem;
	color: rgba(255, 255, 255, 0.54);
}
</style>