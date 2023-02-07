<template>
	<div class="page check-address sia">
		<div class="page-content">
			<div class="upper-content">
				<form class="panel" @submit.prevent="onSubmit">
					<div class="control">
						<label>Net Address (address and port)</label>
						<input type="text" v-model="netAddress" />
					</div>
					<div class="control">
						<label>Network</label>
						<select v-model="network">
							<option value="sia">Sia - Mainnet</option>
							<option value="zen">Zen - Testnet</option>
						</select>
					</div>
					<div class="button-wrapper">
						<button class="btn btn-success btn-inline">Check My Host</button>
					</div>
				</form>
				<div class="recent-hosts" v-if="showRecents">
					<h5>Recent Hosts</h5>
					<div class="host-group">
						<div v-for="h in recentSiaHosts" :key="h.netaddress">
							<router-link
								:class="h.network"
								:to="{ name: 'check results', params: { address: encodeURIComponent(h.netaddress) } }">{{ h.netaddress }}</router-link>
						</div>
					</div>
				</div>
			</div>
			<logos />
		</div>
	</div>
</template>

<script>
import Logos from '@/components/Logos';

export default {
	components: {
		Logos
	},
	data() {
		return {
			network: 'sia',
			netAddress: '',
			recentSiaHosts: [],
			recentSCPHosts: []
		};
	},
	computed: {
		showRecents() {
			return this.recentSiaHosts?.length > 0;
		}
	},
	beforeMount() {
		this.onStorageUpdate();
	},
	created() {
		window.addEventListener('storage', this.onStorageUpdate);
	},
	destroyed() {
		window.removeEventListener('storage', this.onStorageUpdate);
	},
	methods: {
		onStorageUpdate() {
			try {
				let hosts;
				const siaHosts = [], dups = {};

				try {
					hosts = JSON.parse(localStorage.getItem('checkedHosts') || []);
				} catch (ex) {}

				if (!Array.isArray(hosts))
					hosts = [];

				for (let i = 0; i < hosts.length; i++) {
					const h = hosts[i];

					if (dups[`${h.a}-${h.n}`])
						continue;

					dups[`${h.a}-${h.n}`] = true;

					if (h.n.toLowerCase() === 'sia' || h.n.toLowerCase() === 'zen') {
						siaHosts.push({
							network: h.n,
							netaddress: h.a
						});
					}
				}

				if (siaHosts.length > 5)
					siaHosts.splice(5);

				this.recentSiaHosts = siaHosts;
			} catch (ex) {
				console.error('CheckAddress.onRecentHostsUpdate', ex);
			}
		},
		onSubmit() {
			console.log('onSubmit', this.netAddress, this.network);
			this.$router.push({
				name: 'check results',
				params: {
					address: encodeURIComponent(this.netAddress.toLowerCase()),
					network: this.network.toLowerCase()
				}
			});
		}
	}
};
</script>

<style lang="stylus" scoped>
.page.check-address {
	padding: 0;
}

.page-content {
	display: grid;
	width: 100%;
	height: 100%;
	margin: auto;
	grid-template-rows: minmax(0, 1fr) auto;
	overflow: hidden;
}

.upper-content {
	display: grid;
	height: 100%;
	align-content: safe center;
	grid-gap: 15px;
	padding: 15px;
	overflow-y: auto;

	form.panel {
		max-width: 500px;
		margin: 0 auto;
	}
}

h5 {
	text-align: center;
	margin-bottom: 5px;
}

.host-group {
	margin-bottom: 8px;
	text-align: center;

	a {
		margin-bottom: 1px;

		&.sia {
			color: primary;
		}

		&.scprime {
			color: primary-scp;
		}
	}
}

.button-wrapper {
	text-align: center;
}
</style>