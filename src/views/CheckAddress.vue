<template>
	<div class="page check-address">
		<div class="page-content">
			<div class="upper-content">
				<form class="panel">
					<div class="control">
						<label>Net Address (address and port)</label>
						<input type="text" v-model="netAddress" @change="onChangeNetAdress" />
					</div>
					<div class="control">
						<label>Network</label>
						<select v-model="network" @change="onChangeNetwork">
							<option value="sia">Sia</option>
							<option value="scprime">SCPrime</option>
						</select>
					</div>
					<div class="button-wrapper">
						<button class="btn btn-success btn-inline" @click.prevent="onSubmit">Check My Host</button>
					</div>
				</form>
				<div class="recent-hosts" v-if="recentSiaHosts.length !== 0 || recentSCPHosts.length !== 0">
					<h5>Recent Hosts</h5>
					<div class="host-group" v-if="recentSiaHosts.length !== 0">
						<router-link
							v-for="h in recentSiaHosts" :key="h.netaddress"
							:class="h.network"
							:to="{ name: 'check results', params: { address: encodeURIComponent(h.netaddress), network: h.network } }">{{ h.netaddress }}</router-link>
					</div>
					<div class="host-group" v-if="recentSCPHosts.length !== 0">
						<router-link
							v-for="h in recentSCPHosts" :key="h.netaddress"
							:class="h.network"
							:to="{ name: 'check results', params: { address: encodeURIComponent(h.netaddress), network: h.network } }">{{ h.netaddress }}</router-link>
					</div>
				</div>
			</div>
			<logos />
		</div>
	</div>
</template>

<script>
import { mapActions } from 'vuex';
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
		...mapActions(['setStyle']),
		onStorageUpdate() {
			try {
				let hosts;
				const siaHosts = [], scpHosts = [], dups = {};

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

					switch (h.n.toLowerCase()) {
					case 'sia':
						siaHosts.push({
							network: h.n,
							netaddress: h.a
						});
						break;
					case 'scprime':
						scpHosts.push({
							network: h.n,
							netaddress: h.a
						});
						break;
					}
				}

				if (siaHosts.length > 5)
					siaHosts.splice(5);

				if (scpHosts.length > 5)
					scpHosts.splice(5);

				this.recentSiaHosts = siaHosts;
				this.recentSCPHosts = scpHosts;
				this.netAddress = localStorage.getItem('lastAddress') || '';
				this.network = localStorage.getItem('network') || 'sia';
				this.setStyle(this.network);
			} catch (ex) {
				console.error('CheckAddress.onRecentHostsUpdate', ex);
			}
		},
		onSubmit() {
			this.$router.push({
				name: 'check results',
				params: {
					address: encodeURIComponent(this.netAddress.toLowerCase()),
					network: this.network
				}
			});
		},
		onChangeNetwork() {
			try {
				localStorage.setItem('network', this.network);
				this.setStyle(this.network);
			} catch (ex) {
				console.error('CheckAddress.onChangeNetwork', ex);
			}
		},
		onChangeNetAdress() {
			try {
				localStorage.setItem('lastAddress', this.netAddress);
			} catch (ex) {
				console.error('CheckAddress.onChangeNetwork', ex);
			}
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
		display: block;
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