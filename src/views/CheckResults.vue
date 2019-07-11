<template>
	<div class="page">
		<transition name="fade" v-if="loaded" appear>
			<div class="page-content">
				<display-panel class="connection-step" :extras="connectionExtras" v-if="loaded && step >= 0" title="Initial Connection Check" icon="wifi" :error="step === 0">
					<template v-if="step > 0">
						It looks like something is listening at that net address
					</template>
					<template v-else>
						We can't connect to your host at that net address
					</template>
				</display-panel>
				<display-panel class="connection-step" v-if="loaded && step >= 1" title="Host Database Check" icon="database" :error="step === 1" :extras="hostDBExtras">
					<template v-if="step > 1">
						You appear to be in our host database
					</template>
					<template v-else>
						We couldn't find your net address in our host db
					</template>
				</display-panel>
				<display-panel class="connection-step" v-if="loaded && step >= 2" title="Host Connection Check" icon="cogs" :error="step === 2" :extras="scanExtras">
					<template v-if="step > 2">
						We were able to get the latest configuration from your host!
					</template>
					<template v-else>
						We couldn't retrieve settings from your host
					</template>
				</display-panel>
				<display-panel class="connection-step" v-if="loaded && error" title="Error Message" icon="exclamation-triangle" :error="true">
					{{ error }}
				</display-panel>
				<display-panel class="connection-step" v-if="loaded && reasons && reasons.length > 0" title="Possible Causes" icon="search" :error="true">
					<ul>
						<li v-for="item in reasons" :key="item">{{item}}</li>
					</ul>
				</display-panel>
				<display-panel class="connection-step" v-if="loaded && resolutions && resolutions.length > 0" title="Things to Try" icon="wrench" :error="true">
					<ul>
						<li v-for="item in resolutions" :key="item">{{item}}</li>
					</ul>
				</display-panel>
				<template v-if="loaded && step >= 3">
					<div class="step-title">Current Configuration</div>
					<display-panel class="setting" v-for="setting in settings" :key="setting.label" :icon="setting.icon">
						<div class="setting-title">{{ setting.title }}</div>
						<div class="setting-value">{{ setting.value }}</div>
						<div class="setting-avg" v-if="setting.average">Average: {{ setting.average }}</div>
					</display-panel>
				</template>
			</div>
		</transition>
		<loader v-else text="Checking your host... Please wait..." />
	</div>
</template>

<script>
import DisplayPanel from '@/components/DisplayPanel';
import Loader from '@/components/Loader';

import { BigNumber } from 'bignumber.js';
import { getAverageSettings, getConnectability } from '@/utils/api';
import { numberToString, formatByteString, formatSiacoinString, formatStoragePriceString } from '@/utils/index';

export default {
	components: {
		DisplayPanel,
		Loader
	},
	props: {
		address: String
	},
	data() {
		return {
			loaded: false,
			settings: [
				{
					key: 'version',
					title: 'Version',
					icon: 'code-branch'
				},
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
					icon: 'hdd',
					format: 'siacoin'
				},
				{
					key: 'contract_price',
					title: 'Contract Price',
					icon: 'file-contract',
					format: 'siacoin'
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
			step: 0,
			resolvedIP: null,
			latency: null,
			publicKey: null,
			reasons: [],
			resolutions: [],
			dbEntry: {},
			error: null
		};
	},
	computed: {
		connectionExtras() {
			let extras = [{
				key: 'Net Address',
				value: this.address
			}];

			if (this.resolvedIP && Array.isArray(this.resolvedIP)) {
				this.resolvedIP.forEach((ip, i) => {
					extras.push({
						key: `Resolved IP ${i > 0 ? i + 1 : ''}`.trim(),
						value: ip
					});
				});
			}

			return extras;
		},
		hostDBExtras() {
			let extras = [];

			if (this.publicKey) {
				extras.push({
					key: 'Public Key',
					value: this.publicKey
				});
			}

			if (this.dbEntry && this.dbEntry.firstseen) {
				extras.push({
					key: 'First Block Seen',
					value: this.dbEntry.firstseen
				});
			}

			return extras;
		},
		scanExtras() {
			let extras = [];

			if (this.latency) {
				extras.push({
					key: 'Response Time',
					value: `${this.latency}ms`
				});
			}

			return extras;
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

				this.publicKey = resp.public_key;

				console.log(resp.message);

				if (resp.message !== 'success')
					this.error = resp.message;

				if (avgResp.type !== 'success') {
					console.log(avgResp.message);
					return;
				}

				this.buildSettings(resp.external_settings, avgResp.settings);

				this.latency = !resp.latency || resp.latency <= 0 ? null : resp.latency;
				this.resolvedIP = resp.resolved_ip && resp.resolved_ip.length > 0 ? resp.resolved_ip : [];
				this.reasons = resp.reasons || [];
				this.resolutions = resp.resolutions || [];
				this.dbEntry = resp.db_entry || {};
				this.loaded = true;
			} catch (ex) {
				console.log(ex);
			}
		},
		buildSettings(settings, avgSettings) {
			this.settings = this.settings.map(s => {
				try {
					s.value = this.formatValue(settings[s.key], s.format);
					s.average = avgSettings[s.key] ? this.formatValue(avgSettings[s.key], s.format) : null;
				} catch (ex) { console.log(ex); }

				return s;
			});
		},
		formatValue(val, format) {
			format = format || '';

			switch (format.toLowerCase()) {
			case 'storage':
				val = new BigNumber(val);
				return formatStoragePriceString(val, 2);
			case 'siacoin':
				val = new BigNumber(val);
				return formatSiacoinString(val, 2);
			case 'bandwidth':
				val = new BigNumber(val);
				return formatSiacoinString(val.times(1e12), 2);
			case 'bytes':
				val = new BigNumber(val);
				return formatByteString(val, 2);
			case 'number':
				val = new BigNumber(val);
				return numberToString(val, 1000, ['', 'K', 'M', 'B'], 0);
			case 'boolean':
				return val ? 'Yes' : 'No';
			default:
				return val.toString();
			}
		}
	}
};
</script>

<style lang="stylus" scoped>
ul {
	margin: 0;
	padding-left: 20px;

	> li {
		margin-bottom: 5px;
	}
}

.panel {
	max-width: 100%;
}

.host-address {
	background: #efefef;
    padding: 5px 8px;
    border-radius: 3px;
    color: #19cf86;
    font-size: 0.8rem;
    margin-top: 10px;
	width: 100%;
	overflow-x: auto;
}

.step-title {
	font-size: 1.2rem;
	color: rgba(0, 0, 0, 0.4);
}

.page-content {
	grid-template-columns: minmax(0, 1fr);
}

.setting-title {
	color: primary;
	font-size: 0.8rem;
	margin-bottom: 5px;

	.panel-content {
		width: 100%;
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
		grid-template-columns: 40vw 40vw;

		.connection-step, .step-title {
			grid-column: 1 / span 2;
		}
	}
}

@media screen and (min-width: 1200px) {
	.page-content {
		grid-template-columns: 33vw 33vw;
	}
}
</style>
