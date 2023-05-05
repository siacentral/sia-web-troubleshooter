<template>
	<div class="page">
		<transition name="fade" mode="out-in" appear>
			<div class="troubleshoot-content page-content" v-if="loaded">
				<div class="buttons text-right">
					<router-link class="btn btn-inline btn-back" :to="{ name: 'check address' }"><font-awesome :icon="['fad', 'arrow-left']" /> Back</router-link>
					<button class="btn btn-inline btn-retry" @click="onChangeSettings"><font-awesome :icon="['fad', 'cogs']" /></button>
					<button class="btn btn-inline btn-retry" @click="checkHost"><font-awesome :icon="['fad', 'sync']" />Retry</button>
				</div>
				<template v-if="errors.length !== 0">
					<h3 class="step-title">Issues</h3>
					<display-panel v-for="(error, i) in errors"
						:key="i"
						class="connection-step"
						icon="exclamation-circle"
						:severity="error.severity"
						:moreInfoLink="showMoreInfo(error)">
						{{ error.message }}
						<template slot="extras" v-if="(Array.isArray(error.reasons) && error.reasons.length !== 0) || (Array.isArray(error.resolutions) && error.resolutions.length !== 0)">
							<div class="extras-grid">
								<template v-if="Array.isArray(error.reasons) && error.reasons.length !== 0">
									<div class="extra-title">Reasons</div>
									<div class="extra-value">
										<ul>
											<li v-for="(reason, i) in error.reasons" :key="i">{{ reason }}</li>
										</ul>
									</div>
								</template>
								<template v-if="Array.isArray(error.resolutions) && error.resolutions.length !== 0">
									<div class="extra-title">Resolutions</div>
									<div class="extra-value">
										<ul>
											<li v-for="(resolution, i) in error.resolutions" :key="i">{{ resolution }}</li>
										</ul>
									</div>
								</template>
							</div>
						</template>
					</display-panel>
				</template>
				<div class="tests">
					<div class="host-working" v-if="errors.length === 0">
						All tests passed! Host working with no issues.
					</div>
					<div :class="{ 'test': true, 'test-passed': result.passed, 'test-failed': !result.passed }" v-for="result in results" :key="result.name">
						<font-awesome :icon="['fad', testIcon(result.name)]" />{{ testName(result.name, result.passed) }}
					</div>
				</div>
				<div>
					<benchmark-results :benchmark="benchmark" :average="avgBenchmark" />
				</div>
				<div class="info">
					<div class="info-title">Version</div>
					<div class="info-value">{{ version }}</div>
					<div class="info-title">Address</div>
					<div class="info-value">{{ netaddress }}</div>
					<div class="info-title">Public Key</div>
					<div class="info-value"><input :value="publicKey" readonly /></div>
					<div class="info-title">First Seen</div>
					<div class="info-value">{{ firstAnnouncement }}</div>
					<div class="info-title">Estimated Uptime</div>
					<div class="info-value">{{ estimatedUptime }}</div>
					<div class="info-title" />
					<div class="info-value text-right"><button class="host-monitor-link" @click.prevent="openSiaStatsMonitor" :disabled="openingSiaStats"><font-awesome :icon="['fad', 'external-link']" /> view on SiaStats</button></div>
				</div>
				<div class="storage">
					<font-awesome :icon="['fad', 'hdd']" />
					<div class="usage-info">
						<div class="title">Storage Usage</div>
						<div class="storage-bar"><div class="bar-fill" :style="{ 'width': storagePct }" /></div>
						<div class="usage" v-html="storageUsageStr" />
					</div>
				</div>
				<div class="registry" v-if="showRegistry">
					<font-awesome :icon="['fad', 'database']" />
					<div class="usage-info">
						<div class="title">Registry Usage</div>
						<div class="storage-bar"><div class="bar-fill" :style="{ 'width': registryPct }" /></div>
						<div class="usage" v-html="registryUsageStr" />
					</div>
				</div>
				<host-settings network="sia" :settings="hostSettings" :average="averages.settings || {}" />
				<logos class="footer" />
			</div>
			<loader v-else text="Checking your host... Please wait..." />
		</transition>
		<change-settings-modal v-if="modal === 'settings'" @close="modal = null" />
	</div>
</template>

<script>
import BenchmarkResults from '@/components/BenchmarkResults';
import ChangeSettingsModal from '@/components/ChangeSettingsModal';
import DisplayPanel from '@/components/DisplayPanel';
import HostSettings from '@/components/HostSettings';
import Loader from '@/components/Loader';
import Logos from '@/components/Logos';

import { mapState, mapActions } from 'vuex';
import { getSiaCoinPrice, getSiaAverageSettings, getSiaConnectability, getSiaHost, getZenAverageSettings, getZenConnectability, getZenHost } from '@/utils/api';
import { formatByteString, formatDate, formatNumber } from '@/utils/format';

export default {
	components: {
		BenchmarkResults,
		ChangeSettingsModal,
		DisplayPanel,
		HostSettings,
		Loader,
		Logos
	},
	props: {
		address: String,
		network: String
	},
	data() {
		return {
			loaded: false,
			results: [
				{ name: 'Net address resolution', passed: false },
				{ name: 'Host Announcement', passed: false },
				{ name: 'Connectability', passed: false },
				{ name: 'Retrieve Settings', passed: false },
				{ name: 'SiaMux', passed: false }
			],
			hostDetail: {},
			hostSettings: {},
			priceTable: null,
			averages: {},
			resolvedIP: [],
			netaddress: '',
			latency: 0,
			scanLatency: 0,
			publicKey: null,
			scanErrors: [],
			announcements: [],
			error: null,
			modal: null,
			openingSiaStats: false
		};
	},
	computed: {
		...mapState(['currency', 'exchangeRate', 'dataUnit']),
		errors() {
			let e = [];

			if (Array.isArray(this.scanErrors))
				e = e.concat(this.scanErrors);

			if (this.hostDetail.benchmark && this.hostDetail.benchmark.error) {
				e.push({
					message: 'RHP3 Benchmark failed',
					reasons: [this.hostDetail.benchmark.error],
					severity: 'warning',
					type: 'benchmark'
				});
			}

			return e;
		},
		searchNetAddress() {
			const components = this.address.split(':'),
				defaultPort = '9982';

			if (components.length === 0)
				return this.address;
			else if (components.length === 1)
				return `${this.address}:${defaultPort}`;

			const port = parseInt(components[components.length - 1], 10);

			if (!port || isNaN(port) || !isFinite(port))
				return `${this.address}:${defaultPort}`;

			return this.address;
		},
		hostPort() {
			const addr = this.hostSettings && this.hostSettings.netaddress ? this.hostSettings.netaddress : '',
				p = addr.split(':');

			if (p.length === 1)
				return '';

			return p[p.length - 1];
		},
		remainingRegEntries() {
			return this.priceTable && this.priceTable.registryentriesleft && isFinite(this.priceTable.registryentriesleft) ? this.priceTable.registryentriesleft : 0;
		},
		totalRegEntries() {
			return this.priceTable && this.priceTable.registryentriestotal && isFinite(this.priceTable.registryentriestotal) ? this.priceTable.registryentriestotal : 0;
		},
		siaMuxPort() {
			return this.hostSettings && this.hostSettings.sia_mux_port ? this.hostSettings.sia_mux_port : '';
		},
		version() {
			if (this.hostSettings && typeof this.hostSettings.make === 'string' && this.hostSettings.make.length !== 0)
				return `${this.hostSettings.make} ${this.hostSettings.model}`;

			if (this.hostSettings && typeof this.hostSettings.version === 'string' && this.hostSettings.version.length !== 0)
				return `Sia ${this.hostSettings.version}`;

			return 'unknown';
		},
		avgBenchmark() {
			return this.averages.benchmarks || {};
		},
		firstAnnouncement() {
			if (!Array.isArray(this.announcements) || this.announcements.length === 0)
				return null;

			const announcement = this.announcements[this.announcements.length - 1];

			return `${formatDate(new Date(announcement.timestamp))}`;
		},
		lastAnnouncement() {
			if (!Array.isArray(this.announcements) || this.announcements.length === 0 || this.announcements.length === 1)
				return null;

			const announcement = this.announcements[0];

			return `${formatDate(new Date(announcement.timestamp))}`;
		},
		estimatedUptime() {
			return this.hostDetail && this.hostDetail.estimated_uptime ? `${this.hostDetail.estimated_uptime}%` : `0%`;
		},
		storageUsageStr() {
			const rem = this.hostSettings && this.hostSettings.remaining_storage ? this.hostSettings.remaining_storage : 1,
				total = this.hostSettings && this.hostSettings.total_storage ? this.hostSettings.total_storage : 1,
				used = total - rem,
				usedStr = formatByteString(used, this.dataUnit, 2),
				totalStr = formatByteString(total, this.dataUnit, 2);

			return `${usedStr.value} <span class="currency-display">${usedStr.label}</span> &sol; ${totalStr.value} <span class="currency-display">${totalStr.label}</span>`;
		},
		storagePct() {
			const rem = this.hostSettings && this.hostSettings.remaining_storage ? this.hostSettings.remaining_storage : 1,
				total = this.hostSettings && this.hostSettings.total_storage ? this.hostSettings.total_storage : 1,
				used = total - rem;

			return `${(used / total) * 100}%`;
		},
		showRegistry() {
			return this.totalRegEntries > 0;
		},
		registryUsageStr() {
			if (this.totalRegEntries < this.remainingRegEntries)
				return '';

			const used = this.totalRegEntries - this.remainingRegEntries;

			return `${formatNumber(used, 0)} <span class="currency-display">entries</span> &sol; ${formatNumber(this.totalRegEntries, 0)} <span class="currency-display">entries</span>`;
		},
		registryPct() {
			if (this.totalRegEntries < this.remainingRegEntries || this.totalRegEntries === 0)
				return '0%';

			return `${((this.totalRegEntries - this.remainingRegEntries) / this.totalRegEntries) * 100}%`;
		},
		benchmark() {
			if (!this.hostDetail)
				return null;

			return this.hostDetail.benchmark;
		}
	},
	mounted() {
		this.newCurrency = this.currency;
		this.newUnit = this.dataUnit;
		this.updateRecentHosts();
		this.checkHost();
	},
	methods: {
		...mapActions(['setCurrency', 'setDataUnit', 'setExchangeRate']),
		showMoreInfo(err) {
			if (err.message.indexOf('Sia versions below v1.5.4 will be on the old chain after this date') !== -1)
				return 'https://blog.sia.tech/launching-the-sia-foundation-ee47dfab4d2c';

			return null;
		},
		updateRecentHosts() {
			try {
				let h;

				try {
					h = JSON.parse(localStorage.getItem('checkedHosts') || []);
				} catch (ex) {}

				if (!Array.isArray(h))
					h = [];

				h = h.filter(h => h.a !== this.address);

				h.unshift({
					a: this.address,
					n: 'sia'
				});

				if (h.length > 100)
					h.splice(100);

				localStorage.setItem('checkedHosts', JSON.stringify(h));
			} catch (ex) {
				console.error('error setting recent hosts: ', ex);
			}
		},
		onChangeSettings() {
			this.modal = 'settings';
		},
		testName(test, passed) {
			const icons = {
				'net address resolution': 'Net Address Resolved',
				'host announcement': 'Host Announced',
				'connectability': `RHP2 Connected${passed && this.hostPort ? ' (:' + this.hostPort + ')' : ''}`,
				'retrieve settings': 'Settings Retrieved',
				'siamux': `RHP3 Connected${passed && this.siaMuxPort ? ' (:' + this.siaMuxPort + ')' : ''}`
			};

			return icons[test.toLowerCase()];
		},
		testIcon(test) {
			const icons = {
				'Net address resolution': 'wifi',
				'Host Announcement': 'database',
				'Connectability': 'wifi',
				'Retrieve Settings': 'cogs',
				'SiaMux Port Open': 'wifi'
			};

			return icons[test] || 'wifi';
		},
		async checkConnection() {
			let resp;
			switch (this.network) {
			case 'zen':
				resp = await getZenConnectability(this.searchNetAddress);
				break;
			default:
				resp = await getSiaConnectability(this.searchNetAddress);
				break;
			}

			this.netaddress = resp.netaddress;
			this.resolved = resp.resolved;
			this.connected = resp.connected;
			this.announced = resp.announced;
			this.scanned = resp.scanned;
			this.publicKey = resp.public_key;
			this.hostSettings = resp.external_settings;
			this.healthReport = resp.health_report;
			this.priceTable = resp.price_table || {};
			this.results = resp.results;
			this.latency = isNaN(resp.latency) || !isFinite(resp.latency) ? 0 : resp.latency;
			this.scanLatency = isNaN(resp.scan_latency) || !isFinite(resp.scan_latency) ? 0 : resp.scan_latency;
			this.resolvedIP = resp.resolved_ips && resp.resolved_ips.length > 0 ? resp.resolved_ips : [];
			this.scanErrors = Array.isArray(resp.errors) ? resp.errors : [];
			this.announcements = Array.isArray(resp.announcements) ? resp.announcements : [];

			this.scanErrors.sort((a, b) => {
				let aV = a.severity === 'severe' ? 2 : a.severity === 'warning' ? 1 : 0,
					bV = b.severity === 'severe' ? 2 : b.severity === 'warning' ? 1 : 0;

				if (aV > bV)
					return -1;

				if (aV < bV)
					return 1;

				return 0;
			});

			if (this.publicKey?.trim().length !== 0) {
				await Promise.allSettled([
					this.loadHost(this.publicKey)
				]);
			}
		},
		async loadAverageSettings() {
			switch (this.network) {
			case 'zen':
				this.averages = await getZenAverageSettings();
				break;
			default:
				this.averages = await getSiaAverageSettings();
			}
		},
		async loadPricing() {
			const pricing = await getSiaCoinPrice();

			this.setExchangeRate(pricing);
		},
		async loadHost() {
			switch (this.network) {
			case 'zen':
				this.hostDetail = await getZenHost(this.publicKey);
				break;
			default:
				this.hostDetail = await getSiaHost(this.publicKey);
				break;
			}
		},
		async openSiaStatsMonitor() {
			try {
				if (this.openingSiaStats)
					return;

				this.openingSiaStats = true;

				const url = `https://siastats.info:3510/hosts-api/get_id/${encodeURIComponent(this.publicKey)}`,
					resp = await fetch(url),
					{ status, id } = await resp.json();

				if (status !== 'ok')
					return;

				const a = document.createElement('a');
				a.href = `https://siastats.info/hosts?=${encodeURIComponent(id)}`;
				a.target = '_blank';
				a.style.display = 'hidden';
				a.style.opacity = 0;
				a.style.position = 'fixed';
				document.body.appendChild(a);
				a.click();
				document.body.removeChild(a);
			} catch (ex) {
				console.error(ex);
			} finally {
				this.openingSiaStats = false;
			}
		},
		async checkHost() {
			try {
				this.loaded = false;
				this.netaddress = this.address;

				const results = (await Promise.allSettled([
					this.checkConnection(),
					this.loadAverageSettings(),
					this.loadPricing()
				])).filter(r => r.status === 'rejected').map(r => ({
					message: r.reason.toString(),
					severity: 'severe',
					type: 'troubleshoot'
				}));

				this.scanErrors.unshift(...results);

				this.loaded = true;
			} catch (ex) {
				console.log(ex);
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
.troubleshoot-content.page-content {
	display: grid;
	width: 100%;
	height: 100%;
	grid-gap: 15px;
	max-width: 1200px;
	margin: auto;
	align-content: safe center;

	@media screen and (min-width: 767px) {
		grid-template-columns: auto minmax(0, 1fr);
		width: 80vw;
	}
}

.buttons, .footer, .unit-select, .connection-step, .host-working {
	grid-column: 1 / -1;
}

.buttons {
	text-align: right;

	button, a {
		padding: 0;
		background: transparent;
		color: rgba(255, 255, 255, 0.54);
		text-decoration: none;

		svg {
			margin-right: 8px;
		}
	}

	.btn-back {
		float: left;
	}

	&:last-child {
		margin-right: 0;
	}
}

.storage, .registry {
	display: grid;
	background: bg-accent;
	padding: 8px;
	border-radius: 4px;
	grid-gap: 15px;
	grid-template-columns: 45px 1fr;
	grid-column: 1 / -1;
	align-items: center;
	box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);

	svg {
		display: block;
		margin: 0 auto;
		width: 28px;
		height: auto;

		.fa-secondary {
			fill: light-gray;
		}
	}

	.title {
		text-align: center;
		font-size: 0.8rem;
		margin-bottom: 8px;
	}

	.storage-bar {
		width: 100%;
		background: dark-gray;
		border-radius: 16px;
		height: 8px;
		margin-bottom: 5px;
		overflow: hidden;

		.bar-fill {
			background: primary;
			height: 8px;
			border-radius: 16px;
		}
	}

	.usage {
		font-size: 0.8rem;
		color: rgba(255, 255, 255, 0.54);
		text-align: center;
	}

}

.registry svg {
	width: auto;
	height: 28px;
}

.split-button {
	text-align: center;
    font-size: 0;

	.btn {
		display: inline-block;
		width: auto;
		border: none;
		border-radius: 0;
		box-shadow: none;
		border-right: 1px solid #000000;
		background: #2b2b2b;
		color: rgba(255, 255, 255, 0.84);
		transition: all 0.3s linear;
		font-size: 0.8rem;
		padding: 5px 15px;

		&:first-of-type {
			border-top-left-radius: 16px;
			border-bottom-left-radius: 16px;
		}

		&:last-of-type {
			border-top-right-radius: 16px;
			border-bottom-right-radius: 16px;
			border-right: none;
		}

		&.btn-active {
			background: primary;
			color: rgba(0, 0, 0, 0.54);
		}
	}
}

.host-working {
	font-size: 0.8rem;
	margin-bottom: 5px;
	color: primary;
	text-align: center;
}

.tests {
	display: grid;
	border-radius: 8px;
	padding: 15px 0;
	grid-gap: 10px;
	align-content: space-between;

	.test {
		display: grid;
		grid-gap: 10px;
		grid-template-columns: 30px 1fr;

		svg {
			display: block;
			margin: 0 auto;
		}

		&.test-passed {
			.fa-primary {
				fill: lighten(primary, 20%);
			}

			.fa-secondary {
				fill: primary;
			}
		}

		&.test-failed {
			.fa-primary {
				fill: lighten(negative-accent, 20%);
			}

			.fa-secondary {
				fill: negative-accent;
			}
		}
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

.info {
	display: grid;
	padding: 15px;
	grid-gap: 15px;
	background: bg-accent;
	border-radius: 4px;
	grid-column: 1 / -1;
	align-items: center;
	box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);

	@media screen and (min-width: 767px) {
		grid-template-columns: auto minmax(0, 1fr);
	}

	.info-title {
		color: primary;
		font-size: 0.8rem;
		margin-bottom: 5px;

		@media screen and (min-width: 767px) {
			margin: 0;
			text-align: right;
		}
	}

	.info-value {
		font-size: 1.2rem;

		&.text-right {
			text-align: right;
		}
	}

	input {
		display: block;
		background: transparent;
		border: none;
		outline: none;
		padding: 0;
		height: auto;
		color: inherit;
		font-size: inherit;
		font-family: inherit;
		width: 100%;
		text-overflow: ellipsis;
	}
}

.host-monitor-link {
	font-size: 0.8rem;
	color: rgba(255, 255, 255, 0.4);
	text-decoration: none;
	background: none;
	border: none;
	outline: none;
	cursor: pointer;
	transition: color linear 0.3s;

	&:hover, &:focus, &:active {
		color: primary;
	}

	&:disabled {
		opacity: 0.54;
	}
}

.step-title {
	font-size: 1.2rem;
	color: rgba(255, 255, 255, 0.4);
	margin-bottom: 15px;
	grid-column: 1 / -1;
}
</style>
