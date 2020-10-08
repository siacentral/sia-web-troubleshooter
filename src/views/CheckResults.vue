<template>
	<div class="page">
		<transition name="fade" mode="out-in" appear>
			<div class="troubleshoot-content page-content" v-if="loaded">
				<div class="buttons text-right">
					<button class="btn btn-inline btn-retry" @click="onChangeSettings"><font-awesome :icon="['fad', 'cogs']" /></button>
					<button class="btn btn-inline btn-retry" @click="checkHost"><font-awesome :icon="['fad', 'sync']" />Retry</button>
				</div>
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
						<font-awesome :icon="['fad', testIcon(result.name)]" />{{ testName(result.name) }}
					</div>
					<div :class="{ 'test': true, 'test-passed': benchmarked, 'test-failed': !benchmarked }">
						<font-awesome :icon="['fad', 'tachometer-alt-fast']" />Benchmarked
					</div>
				</div>
				<benchmark-results :benchmark="benchmark" :average="avgBenchmark" />
				<div class="info">
					<div class="info-title">Version</div>
					<div class="info-value">{{ version }}</div>
					<div class="info-title">Address</div>
					<div class="info-value">{{ netaddress }}</div>
					<div class="info-title">SiaMux Port</div>
					<div class="info-value">:{{ siaMuxPort }}</div>
					<div class="info-title">Public Key</div>
					<div class="info-value"><input :value="publicKey" /></div>
					<div class="info-title">First Seen</div>
					<div class="info-value">{{ firstAnnouncement }}</div>
					<div class="info-title">Estimated Uptime</div>
					<div class="info-value">{{ estimatedUptime }}</div>
				</div>
				<div class="storage">
					<font-awesome :icon="['fad', 'hdd']" />
					<div class="usage-info">
						<div class="storage-bar"><div class="bar-fill" :style="{ 'width': storagePct }" /></div>
						<div class="usage" v-html="storageUsageStr" />
					</div>
				</div>
				<host-settings :network="network" :settings="hostSettings" :average="avgSettings" />
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
import { getSiaCoinPrice, getSiaAverageSettings, getSiaConnectability,
	getSCPCoinPrice, getSCPAverageSettings, getSCPConnectability, getSCPHost, getSiaHost } from '@/utils/api';
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
			results: [],
			hostDetail: {},
			hostSettings: {},
			avgSettings: {},
			avgBenchmark: {},
			resolvedIP: [],
			netaddress: '',
			latency: 0,
			scanLatency: 0,
			publicKey: null,
			scanErrors: [],
			announcements: [],
			error: null,
			modal: null
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
					message: 'Benchmark failed',
					reasons: [this.hostDetail.benchmark.error],
					severity: 'severe',
					type: 'benchmark'
				});
			}

			return e;
		},
		hostPort() {
			const addr = this.hostSettings && this.hostSettings.netaddress ? this.hostSettings.netaddress : '',
				p = addr.split(':');

			if (p.length === 1)
				return '';

			return p[p.length - 1];
		},
		siaMuxPort() {
			return this.hostSettings && this.hostSettings.sia_mux_port ? this.hostSettings.sia_mux_port : '';
		},
		version() {
			return this.hostSettings && this.hostSettings.version ? this.hostSettings.version : 'unknown';
		},
		benchmarked() {
			console.log(this.hostDetail.benchmark);
			return this.hostDetail.benchmark && !this.hostDetail.benchmark.error;
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
		benchmarkPassRate() {
			const passed = this.hostDetail && this.hostDetail.benchmark && this.hostDetail.benchmark.passed ? this.hostDetail.benchmark.passed : 0,
				failed = this.hostDetail && this.hostDetail.benchmark && this.hostDetail.benchmark.failed ? this.hostDetail.benchmark.failed : 0;
			let pct = '0%';

			if (passed + failed > 0)
				pct = `${Math.round(passed / (passed + failed) * 10000) / 100}%`;

			return `${formatNumber(passed, 0)} <div class="currency-display">passed</div> ${formatNumber(failed, 0)} <div class="currency-display">failed</div> (${pct} success)`;
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
		benchmark() {
			if (!this.hostDetail || !this.hostDetail.benchmark)
				return null;

			return this.hostDetail.benchmark;
		}
	},
	mounted() {
		this.newCurrency = this.currency;
		this.newUnit = this.dataUnit;
		this.setStyle(this.network);

		this.updateRecentHosts();
		this.checkHost();
	},
	methods: {
		...mapActions(['setStyle', 'setCurrency', 'setDataUnit', 'setExchangeRate']),
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
					n: this.network
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
		testName(test) {
			const icons = {
				'net address resolution': 'Net Address Resolved',
				'host announcement': 'Host Announced',
				'connectability': `Renter Connected${this.hostPort ? ' (:' + this.hostPort + ')' : ''}`,
				'retrieve settings': 'Settings Retrieved',
				'siamux': `SiaMux Connected${this.siaMuxPort ? ' (:' + this.siaMuxPort + ')' : ''}`
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
			try {
				let checker = this.network === 'scprime' ? getSCPConnectability : getSiaConnectability;
				const resp = await checker(this.address);

				this.netaddress = resp.netaddress;
				this.resolved = resp.resolved;
				this.connected = resp.connected;
				this.announced = resp.announced;
				this.scanned = resp.scanned;
				this.publicKey = resp.public_key;
				this.hostSettings = resp.external_settings;
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
			} catch (ex) {
				this.error = ex.message;
				console.error(ex);
			}
		},
		async loadAverageSettings() {
			try {
				let checker = this.network === 'scprime' ? getSCPAverageSettings : getSiaAverageSettings;
				const resp = await checker();

				this.avgSettings = resp.settings;
				this.avgBenchmark = resp.benchmarks;
			} catch (ex) {
				console.error(ex);
			}
		},
		async loadPricing() {
			try {
				let checker = this.network === 'scprime' ? getSCPCoinPrice : getSiaCoinPrice;
				const pricing = await checker();

				this.setExchangeRate(pricing);
			} catch (ex) {
				console.error(ex);
			}
		},
		async loadHost() {
			try {
				let checker = this.network === 'scprime' ? getSCPHost : getSiaHost;

				this.hostDetail = await checker(this.address);
			} catch (ex) {
				console.log(ex);
			}
		},
		async checkHost() {
			try {
				this.loaded = false;

				await Promise.all([
					this.loadHost(),
					this.checkConnection(),
					this.loadAverageSettings(),
					this.loadPricing()
				]);

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

	button {
		padding: 0;
		background: transparent;
		color: rgba(255, 255, 255, 0.54);

		svg {
			margin-right: 8px;
		}
	}

	button:last-child {
		margin-right: 0;
	}
}

.storage {
	display: grid;
	background: bg-accent;
	padding: 15px;
	border-radius: 8px;
	grid-gap: 15px;
	grid-template-columns: 45px 1fr;
	grid-column: 1 / -1;
	align-items: center;

	svg {
		display: block;
		margin: 0 auto;
		width: 28px;
		height: auto;

		.fa-secondary {
			fill: light-gray;
		}
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
	border-radius: 8px;
	grid-column: 1 / -1;
	align-items: center;

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

.step-title {
	font-size: 1.2rem;
	color: rgba(255, 255, 255, 0.4);
	margin-bottom: 15px;
	grid-column: 1 / -1;
}

.scprime {
	.host-working.host-working {
		color: primary-scp;
	}

	.info-title.info-title {
		color: primary-scp;
	}

	.storage-bar .bar-fill.bar-fill {
		background: primary-scp;
	}

	.tests .test.test-passed {
		.fa-primary {
			fill: lighten(primary-scp, 20%);
		}

		.fa-secondary {
			fill: primary-scp;
		}
	}
}
</style>
