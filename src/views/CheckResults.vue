<template>
	<div class="page">
		<transition name="fade" mode="out-in" appear>
			<div class="page-content" v-if="loaded">
				<template v-if="errors.length !== 0">
					<h3 class="step-title">Issues</h3>
					<display-panel class="connection-step" v-for="(error, i) in errors" :key="i" icon="exclamation-circle" :severity="error.severity">
						{{ error.message }}
						<template slot="extras">
							<div class="extras-grid">
								<div class="extra-title">Reasons</div>
								<div class="extra-value">
									<ul>
										<li v-for="(reason, i) in error.reasons" :key="i">{{ reason }}</li>
									</ul>
								</div>
								<div class="extra-title">Resolutions</div>
								<div class="extra-value">
									<ul>
										<li v-for="(resolution, i) in error.resolutions" :key="i">{{ resolution }}</li>
									</ul>
								</div>
							</div>
						</template>
					</display-panel>
				</template>
				<h3 class="step-title">Results ({{ passed }}/{{ total }} Tests Passed)</h3>
				<display-panel class="connection-step" icon="wifi" :severity="resolved ? 'success' : 'severe'">
					<template v-if="resolved">
						Net address resolved
					</template>
					<template v-else>
						Your net address could not be resolved
					</template>
					<template slot="extras">
						<div class="extras-grid">
							<div class="extra-title">Net Address</div>
							<div class="extra-value">{{ netaddress }}</div>
							<template v-for="ip in resolvedIP">
								<div class="extra-title" :key="`title-${ip}`">Resolved IP</div>
								<div class="extra-value" :key="`ip-${ip}`">{{ ip }}</div>
							</template>
						</div>
					</template>
				</display-panel>
				<display-panel class="connection-step" icon="wifi" :severity="connected ? 'success' : 'severe'">
					<template v-if="connected">
						Connected to host
					</template>
					<template v-else>
						Cannot connect to host
					</template>
					<template slot="extras" v-if="connected">
						<div class="extras-grid">
							<div class="extra-title">Latency</div>
							<div class="extra-value">{{ latency }}ms</div>
						</div>
					</template>
				</display-panel>
				<display-panel class="connection-step" icon="database" :severity="announced ? 'success' : 'severe'">
					<template v-if="announced">
						Your announcement is in the host database
					</template>
					<template v-else>
						The net address was not found in the host database
					</template>
					<template slot="extras">
						<div class="extras-grid" v-if="announced">
							<div class="extra-title">Public Key</div>
							<div class="extra-value">{{ publicKey }}</div>
							<template v-if="lastAnnouncement">
								<div class="extra-title">Last Announcement</div>
								<div class="extra-value">{{ lastAnnouncement }}</div>
							</template>
							<template v-if="firstAnnouncement">
								<div class="extra-title">First Announcement</div>
								<div class="extra-value">{{ firstAnnouncement }}</div>
							</template>
						</div>
					</template>
				</display-panel>
				<display-panel class="connection-step" icon="cogs" :severity="scanned ? 'success' : 'severe'">
					<template v-if="scanned">
						Latest settings retrieved from host
					</template>
					<template v-else>
						Settings could not be retrieved from host
					</template>
					<template slot="extras" v-if="scanned">
						<div class="extras-grid">
							<div class="extra-title">Response Time</div>
							<div class="extra-value">{{ scanLatency }}ms</div>
						</div>
					</template>
				</display-panel>
				<template v-if="scanned">
					<div class="step-title">Current Configuration</div>
					<div class="host-settings" v-if="scanned">
						<div class="control">
							<label>Display Currency</label>
							<select v-model="newCurrency">
								<option value="sc">Siacoin</option>
								<optgroup label="Fiat">
									<option value="usd">USD</option>
									<option value="jpy">JPY</option>
									<option value="eur">EUR</option>
									<option value="gbp">GBP</option>
									<option value="aus">AUS</option>
									<option value="cad">CAD</option>
									<option value="rub">RUB</option>
									<option value="cny">CNY</option>
								</optgroup>
								<optgroup label="Crypto">
									<option value="btc">BTC</option>
									<option value="bch">BCH</option>
									<option value="eth">ETH</option>
									<option value="xrp">XRP</option>
									<option value="ltc">LTC</option>
								</optgroup>
							</select>
						</div>
						<div class="control">
							<label>Data Unit</label>
							<select v-model="newUnit">
								<option value="binary">Binary (1024 GiB = 1 TiB)</option>
								<option value="decimal">Decimal (1000 GB = 1 TB)</option>
							</select>
						</div>
						<display-panel class="setting" v-for="setting in formattedSettings" :key="setting.label" :icon="setting.icon">
							<div class="setting-title">{{ setting.title }}</div>
							<div class="setting-value" v-html="setting.value"></div>
							<div class="setting-avg" v-if="setting.average" v-html="`Average: ${setting.average}`"></div>
						</display-panel>
					</div>
				</template>
				<logos />
			</div>
			<loader v-else text="Checking your host... Please wait..." />
		</transition>
	</div>
</template>

<script>
import DisplayPanel from '@/components/DisplayPanel';
import Loader from '@/components/Loader';
import Logos from '@/components/Logos';

import { BigNumber } from 'bignumber.js';
import { mapState, mapActions } from 'vuex';
import { getCoinPrice, getAverageSettings, getConnectability } from '@/utils/api';
import { numberToString, formatBlockTimeString, formatByteString, formatPriceString, formatDataPriceString, formatMonthlyPriceString, formatDate } from '@/utils/format';

export default {
	components: {
		DisplayPanel,
		Loader,
		Logos
	},
	props: {
		address: String
	},
	data() {
		return {
			loaded: false,
			newCurrency: '',
			newUnit: '',
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
					key: 'contract_price',
					title: 'Contract Price',
					icon: 'file-contract',
					format: 'siacoin'
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
			hostSettings: {},
			averageSettings: {},
			connected: false,
			scanned: false,
			resolved: false,
			announced: false,
			resolvedIP: [],
			netaddress: '',
			latency: 0,
			scanLatency: 0,
			publicKey: null,
			passed: 0,
			total: 4,
			errors: [],
			announcements: [],
			error: null
		};
	},
	computed: {
		...mapState(['currency', 'exchangeRate', 'dataUnit']),
		firstAnnouncement() {
			if (!Array.isArray(this.announcements) || this.announcements.length === 0 || this.announcements.length === 1)
				return null;

			const announcement = this.announcements[this.announcements.length - 1];

			return `${announcement.net_address} (${formatDate(new Date(announcement.timestamp))})`;
		},
		lastAnnouncement() {
			if (!Array.isArray(this.announcements) || this.announcements.length === 0)
				return null;

			const announcement = this.announcements[0];

			return `${announcement.net_address} (${formatDate(new Date(announcement.timestamp))})`;
		},
		formattedSettings() {
			return this.settings.reduce((settings, val) => {
				try {
					settings.push({
						...val,
						value: this.formatValue(this.hostSettings[val.key], val.format),
						average: this.avgSettings[val.key] ? this.formatValue(this.avgSettings[val.key], val.format) : null
					});
				} catch (ex) { console.log(ex); }

				return settings;
			}, []);
		}
	},
	mounted() {
		this.newCurrency = this.currency;
		this.newUnit = this.dataUnit;

		this.checkHost();
	},
	methods: {
		...mapActions(['setCurrency', 'setDataUnit', 'setExchangeRate']),
		async checkConnection() {
			try {
				const resp = await getConnectability(this.address);

				this.netaddress = resp.netaddress;
				this.resolved = resp.resolved;
				this.connected = resp.connected;
				this.announced = resp.announced;
				this.scanned = resp.scanned;
				this.publicKey = resp.public_key;
				this.hostSettings = resp.external_settings;
				this.latency = isNaN(resp.latency) || !isFinite(resp.latency) ? 0 : resp.latency;
				this.scanLatency = isNaN(resp.scan_latency) || !isFinite(resp.scan_latency) ? 0 : resp.scan_latency;
				this.resolvedIP = resp.resolved_ips && resp.resolved_ips.length > 0 ? resp.resolved_ips : [];
				this.errors = Array.isArray(resp.errors) ? resp.errors : [];
				this.announcements = Array.isArray(resp.announcements) ? resp.announcements : [];

				if (this.connected)
					this.passed++;

				if (this.scanned)
					this.passed++;

				if (this.announced)
					this.passed++;

				if (this.resolved)
					this.passed++;

				this.errors.sort((a, b) => {
					let aV = a.severity === 'severe' ? 2 : a.severity === 'warning' ? 1 : 0,
						bV = b.severity === 'severe' ? 2 : b.severity === 'warning' ? 1 : 0;

					if (aV > bV)
						return -1;

					if (aV < bV)
						return 1;

					return 0;
				});
			} catch (ex) {
				this.error = ex.message;
				console.error(ex);
			}
		},
		async loadAverageSettings() {
			try {
				const resp = await getAverageSettings();

				this.avgSettings = resp;
			} catch (ex) {
				console.error(ex);
			}
		},
		async loadPricing() {
			try {
				const pricing = await getCoinPrice();

				this.setExchangeRate(pricing);
			} catch (ex) {
				console.error(ex);
			}
		},
		async checkHost() {
			try {
				await Promise.all([
					this.checkConnection(),
					this.loadAverageSettings(),
					this.loadPricing()
				]);

				this.loaded = true;
			} catch (ex) {
				console.log(ex);
			}
		},
		formatValue(val, format) {
			let formatted;

			format = format || '';

			const dataSuffix = this.dataUnit === 'decimal' ? 'TB' : 'TiB';

			switch (format.toLowerCase()) {
			case 'storage':
				val = new BigNumber(val);
				formatted = formatMonthlyPriceString(val, 2, this.dataUnit, this.currency, this.exchangeRate[this.currency]);

				return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}/${dataSuffix}/Mo</span>`;
			case 'siacoin':
				val = new BigNumber(val);
				formatted = formatPriceString(val, 2, this.currency, this.exchangeRate[this.currency]);

				return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}</span>`;
			case 'bandwidth':
				val = new BigNumber(val);
				formatted = formatDataPriceString(val, 2, this.dataUnit, this.currency, this.exchangeRate[this.currency]);

				return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}/${dataSuffix}</span>`;
			case 'bytes':
				val = new BigNumber(val);
				formatted = formatByteString(val, this.dataUnit, 2);

				return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}</span>`;
			case 'number':
				val = new BigNumber(val);
				formatted = numberToString(val, 1000, ['', 'K', 'M', 'B'], 0);

				return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}</span>`;
			case 'blocks':
				formatted = formatBlockTimeString(val);

				return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}</span>`;
			case 'boolean':
				return val ? 'Yes' : 'No';
			default:
				return val.toString();
			}
		}
	},
	watch: {
		newUnit(val) {
			this.setDataUnit(val);
		},
		newCurrency(val) {
			this.setCurrency(val);
		}
	}
};
</script>

<style lang="stylus" scoped>
.page-content {
	max-width: 1000px;
	margin: auto;

	@media screen and (min-width: 767px) {
		width: 80vw;
	}
}

ul {
	margin: 0;
	padding-left: 20px;

	> li {
		margin-bottom: 5px;
		white-space: normal;
		text-align: left;
	}
}

.connection-step {
	margin-bottom: 30px;
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

.host-settings {
	display: grid;
	grid-template-columns: minmax(0, 1fr);
	grid-gap: 15px;

	@media screen and (min-width: 767px) {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}
}

.extras-grid {
	.extra-title {
		margin-bottom: 3px;
	}

	.extra-value {
		margin-bottom: 15px;
	}

	.extra-title, .extra-value {
		text-overflow: ellipsis;
		overflow: hidden;
		white-space: nowrap;

		&:last-child {
			margin-bottom: 0;
		}
	}

	@media screen and (min-width: 767px) {
		display: grid;
		grid-template-columns: repeat(2, minmax(0, auto));
		grid-gap: 15px;
		justify-content: space-between;

		.extra-title, .extra-value {
			margin-bottom: 0;
		}

		.extra-value {
			text-align: right;
		}
	}
}

.step-title {
	font-size: 1.2rem;
	color: rgba(255, 255, 255, 0.4);
	margin-bottom: 15px;
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
	color: rgba(255, 255, 255, 0.54);
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
