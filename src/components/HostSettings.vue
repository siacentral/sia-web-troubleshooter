<template>
	<div class="host-settings">
		<div class="setting">
			<div class="setting-title">Contract Price</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(contractPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(contractPrice)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgContractPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgContractPrice)" />
			</div>
		</div>
		<div class="setting">
			<div class="setting-title">Storage Price</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(storagePrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(storagePrice)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgStoragePrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgStoragePrice)" />
			</div>
			<div class="unit">per {{ dataUnit === 'decimal' ? 'TB' : 'TiB'}} / month</div>
		</div>
		<div class="setting">
			<div class="setting-title">Download Price</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(downloadPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(downloadPrice)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgDownloadPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgDownloadPrice)" />
			</div>
			<div class="unit">per {{ dataUnit === 'decimal' ? 'TB' : 'TiB'}}</div>
		</div>
		<div class="setting">
			<div class="setting-title">Upload Price</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(uploadPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(uploadPrice)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgUploadPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgUploadPrice)" />
			</div>
			<div class="unit">per {{ dataUnit === 'decimal' ? 'TB' : 'TiB'}}</div>
		</div>
		<div class="setting">
			<div class="setting-title">Collateral</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(collateral)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(collateral)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgCollateral)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgCollateral)" />
			</div>
			<div class="unit">per {{ dataUnit === 'decimal' ? 'TB' : 'TiB'}} / month</div>
		</div>
		<div class="setting">
			<div class="setting-title">Sector Access Price</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(sectorAccessPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(sectorAccessPrice)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgSectorAccessPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgSectorAccessPrice)" />
			</div>
			<div class="unit">per sector read</div>
		</div>
		<div class="setting">
			<div class="setting-title">Base RPC Price</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(baseRPCPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(baseRPCPrice)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgBaseRPCPrice)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgBaseRPCPrice)" />
			</div>
			<div class="unit">per RPC call</div>
		</div>
		<div class="setting">
			<div class="setting-title">Max Collateral</div>
			<div class="values">
				<div class="setting-value" v-html="formatSCString(maxCollateral)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(maxCollateral)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatSCString(avgMaxCollateral)" />
				<div class="setting-secondary-value" v-html="formatCurrencyString(avgMaxCollateral)" />
			</div>
			<div class="unit">per contract</div>
		</div>
		<div class="setting">
			<div class="setting-title">Max Contract Duration</div>
			<div class="values">
				<div class="setting-value" v-html="formatNumber(maxDuration, 'Blocks')" />
				<div class="setting-secondary-value" v-html="formatBlockTimeString(maxDuration)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatNumber(avgMaxDuration, 'Blocks')" />
				<div class="setting-secondary-value" v-html="formatBlockTimeString(avgMaxDuration)" />
			</div>
		</div>
		<div class="setting">
			<div class="setting-title">Proof Window Duration</div>
			<div class="values">
				<div class="setting-value" v-html="formatNumber(windowSize, 'Blocks')" />
				<div class="setting-secondary-value" v-html="formatBlockTimeString(windowSize)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatNumber(avgWindowSize, 'Blocks')" />
				<div class="setting-secondary-value" v-html="formatBlockTimeString(avgWindowSize)" />
			</div>
		</div>
		<div class="setting">
			<div class="setting-title">Max Revise Batch Size</div>
			<div class="values">
				<div class="setting-value" v-html="formatByteString(maxReviseSize)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatByteString(avgMaxReviseSize)" />
			</div>
		</div>
		<div class="setting">
			<div class="setting-title">Max Download Batch Size</div>
			<div class="values">
				<div class="setting-value" v-html="formatByteString(maxDownloadSize)" />
			</div>
			<div class="average-values">
				<div class="setting-average-title">Average</div>
				<div class="setting-value" v-html="formatByteString(avgMaxDownloadSize)" />
			</div>
		</div>
	</div>
</template>

<script>
import BigNumber from 'bignumber.js';
import { mapState } from 'vuex';

import { formatNumber, formatByteString, formatSiaPriceString, formatSCPPriceString, formatBlockTimeString } from '@/utils/format';

export default {
	props: {
		average: Object,
		settings: Object,
		network: String
	},
	computed: {
		...mapState(['currency', 'exchangeRate', 'dataUnit']),
		contractPrice() {
			return this.settings && this.settings.contract_price ? this.settings.contract_price : new BigNumber(0);
		},
		storagePrice() {
			const p = this.settings && this.settings.storage_price ? this.settings.storage_price : new BigNumber(0);

			return p.times(4320).times(1e12);
		},
		downloadPrice() {
			const p = this.settings && this.settings.download_price ? this.settings.download_price : new BigNumber(0);

			return p.times(1e12);
		},
		uploadPrice() {
			const p = this.settings && this.settings.upload_price ? this.settings.upload_price : new BigNumber(0);

			return p.times(1e12);
		},
		collateral() {
			const p = this.settings && this.settings.collateral ? this.settings.collateral : new BigNumber(0);

			return p.times(4320).times(1e12);
		},
		maxCollateral() {
			return this.settings && this.settings.max_collateral ? this.settings.max_collateral : new BigNumber(0);
		},
		maxDuration() {
			return this.settings && this.settings.max_duration ? this.settings.max_duration : new BigNumber(0);
		},
		maxDownloadSize() {
			return this.settings && this.settings.max_download_batch_size ? this.settings.max_download_batch_size : new BigNumber(0);
		},
		maxReviseSize() {
			return this.settings && this.settings.max_revise_batch_size ? this.settings.max_revise_batch_size : new BigNumber(0);
		},
		sectorAccessPrice() {
			return this.settings && this.settings.sector_access_price ? this.settings.sector_access_price : new BigNumber(0);
		},
		baseRPCPrice() {
			return this.settings && this.settings.base_rpc_price ? this.settings.base_rpc_price : new BigNumber(0);
		},
		windowSize() {
			return this.settings && this.settings.window_size ? this.settings.window_size : 0;
		},
		avgContractPrice() {
			return this.average && this.average.contract_price ? this.average.contract_price : new BigNumber(0);
		},
		avgStoragePrice() {
			const p = this.average && this.average.storage_price ? this.average.storage_price : new BigNumber(0);

			return p.times(4320).times(1e12);
		},
		avgDownloadPrice() {
			const p = this.average && this.average.download_price ? this.average.download_price : new BigNumber(0);

			return p.times(1e12);
		},
		avgUploadPrice() {
			const p = this.average && this.average.upload_price ? this.average.upload_price : new BigNumber(0);

			return p.times(1e12);
		},
		avgCollateral() {
			const p = this.average && this.average.collateral ? this.average.collateral : new BigNumber(0);

			return p.times(4320).times(1e12);
		},
		avgMaxCollateral() {
			return this.average && this.average.max_collateral ? this.average.max_collateral : new BigNumber(0);
		},
		avgMaxDuration() {
			return this.average && this.average.max_duration ? this.average.max_duration : new BigNumber(0);
		},
		avgMaxDownloadSize() {
			return this.average && this.average.max_download_batch_size ? this.average.max_download_batch_size : new BigNumber(0);
		},
		avgMaxReviseSize() {
			return this.average && this.average.max_revise_batch_size ? this.average.max_revise_batch_size : new BigNumber(0);
		},
		avgSectorAccessPrice() {
			return this.average && this.average.sector_access_price ? this.average.sector_access_price : new BigNumber(0);
		},
		avgBaseRPCPrice() {
			return this.average && this.average.base_rpc_price ? this.average.base_rpc_price : new BigNumber(0);
		},
		avgWindowSize() {
			return this.average && this.average.window_size ? this.average.window_size : 0;
		}
	},
	methods: {
		formatByteString(val, suffix = '') {
			const formatted = formatByteString(val, 2, this.dataUnit);

			return `${formatted.value} <span class="currency-display">${formatted.label}${suffix}</span>`;
		},
		formatNumber(val, suffix = '') {
			return `${formatNumber(val, 0)} <span class="currency-display">${suffix}</span>`;
		},
		formatBlockTimeString(val, suffix = '') {
			const formatted = formatBlockTimeString(val, 2);

			return `${formatted.value} <span class="currency-display">${formatted.label}${suffix}</span>`;
		},
		formatSCString(val, suffix = '') {
			const formatter = this.network === 'scprime' ? formatSCPPriceString : formatSiaPriceString,
				formatted = formatter(val, 2, this.network === 'scprime' ? 'scp' : 'sc');

			return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}${suffix}</span>`;
		},
		formatCurrencyString(val, suffix = '') {
			const formatter = this.network === 'scprime' ? formatSCPPriceString : formatSiaPriceString,
				formatted = formatter(val, 2, this.currency, this.exchangeRate[this.currency]);

			return `${formatted.value} <span class="currency-display">${formatted.label.toUpperCase()}${suffix}</span>`;
		}
	}
};
</script>

<style lang="stylus" scoped>
.host-settings {
	display: grid;
	grid-template-columns: minmax(0, 1fr);
	grid-gap: 15px;
	grid-column: 1 / -1;

	@media screen and (min-width: 767px) {
		grid-template-columns: repeat(2, minmax(0, 1fr));
	}

	@media screen and (min-width: 1200px) {
		grid-template-columns: repeat(3, minmax(0, 1fr));
	}
}

.setting {
    display: grid;
    grid-template-rows: auto 1fr;
    align-items: center;
    background: #25272a;
    padding: 15px;
    border-radius: 8px;
	text-align: center;
	grid-template-columns: minmax(0, 1fr) auto;
	font-size: 1rem;

	.setting-title {
		color: primary;
		margin-bottom: 10px;
		font-size: 0.8em;
		grid-column: 1 / -1;
	}

	.setting-average-title {
		color: rgba(255, 255, 255, 0.54);
		font-size: 0.8em;
		margin-bottom: 3px;
	}

	.unit {
		font-size: 0.8em;
		color: rgba(255, 255, 255, 0.54);
		grid-column: 1 / -1;
		margin-top: 5px;
	}

	.setting-value {
		font-size: 1.2em;
	}

	.average-values {
		font-size: 0.8rem;
		padding: 5px;
		border-radius: 8px;
		background: #2d2f32;

		.setting-value {
			font-size: 1em;
		}
	}

	.setting-secondary-value {
		font-size: 1em;
		color: rgba(255, 255, 255, 0.54);
	}
}

.scprime {
	.setting-title.setting-title, .info-title.info-title {
		color: primary-scp;
	}
}
</style>