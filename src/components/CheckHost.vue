<template>
	<div class="page">
		<div class="page-content">
			<div class="panel connection-step" v-if="loaded && message">
				{{ message }}
			</div>
			<div class="panel connection-step" v-if="loaded && reasons && reasons.length > 0">
				<ul>
					<li v-for="item in reasons" :key="item">{{item}}</li>
				</ul>
			</div>
			<div class="panel connection-step" v-if="loaded && troubleshooting && troubleshooting.length > 0">
				<ul>
					<li v-for="item in troubleshooting" :key="item">{{item}}</li>
				</ul>
			</div>
			<template v-if="loaded && step >= 3">
				<div class="panel setting" v-for="setting in settings" :key="setting.label">
					<div class="setting-title"><font-awesome :icon="['fal', setting.icon]"/>{{ setting.title }}</div>
					<div class="setting-value">{{ setting.value }}</div>
					<div class="setting-avg" v-if="setting.average">Average: {{ setting.average }}</div>
				</div>
			</template>
		</div>
	</div>
</template>

<script>
import { BigNumber } from 'bignumber.js';
import { getAverageSettings, getConnectability } from '@/utils/api';
import { numberToString, formatByteString, formatSiacoinString, formatStoragePriceString } from '@/utils/index';

export default {
	props: {
		address: String
	},
	data() {
		return {
			loaded: false,
			settings: [
				{
					key: 'accepting_contracts',
					title: 'Accepting Contracts',
					icon: 'file-check',
					format: 'boolean'
				},
				{
					key: 'storage_price',
					title: 'Storage Price',
					icon: 'dollar-sign',
					format: 'storage'
				},
				{
					key: 'download_price',
					title: 'Download Price',
					icon: 'download',
					format: 'bandwidth'
				},
				{
					key: 'upload_price',
					title: 'Upload Price',
					icon: 'upload',
					format: 'bandwidth'
				},
				{
					key: 'base_rpc_price',
					title: 'Base RPC Price',
					icon: 'link',
					format: 'siacoin'
				},
				{
					key: 'sector_access_price',
					title: 'Sector Access Price',
					icon: 'dollar-sign',
					format: 'siacoin'
				},
				{
					key: 'contract_price',
					title: 'Contract Price',
					icon: 'file-contract',
					format: 'siacoin'
				},
				{
					key: 'sector_size',
					title: 'Sector Size',
					icon: 'layer-group',
					format: 'bytes'
				},
				{
					key: 'collateral',
					title: 'Collateral',
					icon: 'lock',
					format: 'storage'
				},
				{
					key: 'max_collateral',
					title: 'Max Collateral',
					icon: 'dollar-sign',
					format: 'siacoin'
				},
				{
					key: 'remaining_storage',
					title: 'Remaining Storage',
					icon: 'box-open',
					format: 'bytes'
				},
				{
					key: 'total_storage',
					title: 'Total Storage',
					icon: 'box-full',
					format: 'bytes'
				},
				{
					key: 'max_duration',
					title: 'Max Duration',
					icon: 'clock',
					format: 'blocks'
				},
				{
					key: 'window_size',
					title: 'Window Size',
					icon: 'unlock',
					format: 'blocks'
				},
				{
					key: 'max_download_batch_size',
					title: 'Download Batch Size',
					icon: 'cloud-download',
					format: 'bytes'
				},
				{
					key: 'max_revise_batch_size',
					title: 'Max Revise Batch Size',
					icon: 'cloud-upload',
					format: 'bytes'
				}
			],
			step: 0
		};
	},
	computed: {
		message() {
			switch (this.step) {
			case 1:
				return `"${this.address}" does not appear in our host database`;
			case 2:
				return 'We are unable to retrieve your host\'s current settings';
			case 3:
				return 'Everything looks good! You should be able to form new contracts';
			default:
				return `We cannot connect to the host at "${this.address}"`;
			}
		},
		reasons() {
			switch (this.step) {
			case 1:
				return [
					'Your IP recently changed',
					'You have not announced your host on the Sia network',
					'You announced your host within the last 20 minutes'
				];
			case 2:
				return [
					'Sia is not listening on the specified hosting port',
					'Sia is in a bad state'
				];
			case 3:
				return [];
			default:
				return [
					'Sia is not listening on the specified hosting port',
					'Your firewall is blocking the specified hosting port',
					'Your router is not forwarding traffic to the specified hosting port'
				];
			}
		},
		troubleshooting() {
			switch (this.step) {
			case 1:
				return [
					'Announce your host on the Sia Network',
					`Make sure that the announced net address is the same as "${this.address}"`,
					'If you\'ve recently announced please wait about 10 minutes and try again.'
				];
			case 2:
				return [
					'Make sure that Sia is running',
					'Make sure that Sia is listening on the correct host port',
					`Make sure that the announced net address is the same as "${this.address}"`
				];
			case 3:
				return [];
			default:
				return [
					'Make sure that Sia is running',
					'Make sure that Sia is listening on the correct host port',
					'Make sure you have forwarded the RPC and Host port on your router',
					'Make sure that your firewall is not blocking the RPC and Host port'
				];
			}
		}
	},
	mounted() {
		this.checkHost();
	},
	methods: {
		async checkHost() {
			try {
				const resp = await getConnectability(this.address),
					avgResp = await getAverageSettings();

				if (resp.connected)
					this.step++;

				if (resp.exists_in_hostdb)
					this.step++;

				if (resp.settings_scanned)
					this.step++;

				if (avgResp.type !== 'success') {
					console.log(avgResp.message);
					return;
				}

				this.buildSettings(resp.external_settings, avgResp.settings);

				this.loaded = true;
			} catch (ex) {
				console.log(ex);
			}
		},
		buildSettings(settings, avgSettings) {
			this.settings = this.settings.map(s => {
				s.value = this.formatValue(settings[s.key], s.format);
				s.average = avgSettings[s.key] ? this.formatValue(avgSettings[s.key], s.format) : null;

				return s;
			});
		},
		formatValue(val, format) {
			val = new BigNumber(val);

			switch (format.toLowerCase()) {
			case 'storage':
				return formatStoragePriceString(val, 2);
			case 'siacoin':
				return formatSiacoinString(val, 2);
			case 'bandwidth':
				return formatSiacoinString(val.times(1e12), 2);
			case 'bytes':
				return formatByteString(val, 2);
			case 'number':
				return numberToString(val, 1000, ['', 'K', 'M', 'B'], 0);
			default:
				return val.toString();
			}
		}
	}
};
</script>

<style lang="stylus" scoped>
.page-content {
	grid-template-columns: 1fr;
}

.panel.setting {
	padding-left: 55px;
}

.setting-title {
	color: primary;
	font-size: 0.8rem;
	margin-bottom: 5px;

	svg.svg-inline--fa {
		position: absolute;
		top: 50%;
		left: 15px;
		transform: translateY(-50%);
		height: 30px;
		width: 30px;
		margin: 0;
	}
}

.setting-value {
	font-size: 1.2rem;
}

.setting-avg {
	font-size: 0.8rem;
	color: rgba(0, 0, 0, 0.54);
	margin-top: 5px;
}

@media screen and (min-width: 500px) {
	.page-content {
		grid-template-columns: 30vw 30vw;

		.connection-step {
			grid-column: 1 / span 2;
		}
	}
}
</style>
