<template>
	<div class="contract-groups">
		<div class="alerts">
			<div :class="{ 'alert': true }" v-for="(alert, key) in alerts" :key="key">
				<div class="alert-icon"><font-awesome :icon="['fal', 'exclamation-triangle']" /></div>
				<div class="alert-text">{{ alert.value }}</div>
				<div class="alert-count">{{ alert.count }}</div>
			</div>
		</div>
		<div class="filters">
			<div class="control control-inline">
				<input type="checkbox" v-model="showUSD" :id="getCheckboxID('show-usd')" />
				<label :for="getCheckboxID('show-usd')" >Currency in USD</label>
			</div>
			<div class="control control-inline">
				<input type="checkbox" v-model="showValid" :id="getCheckboxID('show-valid')" />
				<label :for="getCheckboxID('show-valid')" >Show contracts without errors</label>
			</div>
		</div>
		<div class="step-title">Totals</div>
		<div class="group-stats">
			<div class="group-item group-negative">
				<div class="group-title">Lost Revenue</div>
				{{ formatSiacoinString(contracts.totals.lost_revenue) }}
			</div>
			<div class="group-item">
				<div class="group-title">Earned Revenue</div>
				{{ formatSiacoinString(contracts.totals.earned_revenue) }}
			</div>
			<div class="group-item">
				<div class="group-title">Potential Revenue</div>
				{{ formatSiacoinString(contracts.totals.potential_revenue) }}
			</div>
			<div class="group-item group-negative">
				<div class="group-title">Burnt Collateral</div>
				{{ formatSiacoinString(contracts.totals.burnt_collateral) }}
			</div>
			<div class="group-item">
				<div class="group-title">Risked Collateral</div>
				{{ formatSiacoinString(contracts.totals.risked_collateral) }}
			</div>
			<div class="group-item">
				<div class="group-title">Average Daily Revenue</div>
				{{ formatSiacoinString(contracts.totals.daily_revenue) }}
			</div>
			<div class="group-item group-negative">
				<div class="group-title">Failed Contracts</div>
				{{ contracts.totals.failed_count.toString(10) }}
			</div>
			<div class="group-item">
				<div class="group-title">Successful Contracts</div>
				{{ contracts.totals.success_count.toString(10) }}
			</div>
			<div class="group-item">
				<div class="group-title">Ongoing Contracts</div>
				{{ contracts.totals.ongoing_count.toString(10) }}
			</div>
		</div>
		<contract-group v-for="group in groups" :key="group" :showValid="showValid" :group="contracts[group]" />
	</div>
</template>

<script>
import ContractGroup from '@/components/contracts/ContractGroup';

import { BigNumber } from 'bignumber.js';
import { formatSiacoinString, formatSCToUSDString } from '@/utils';

export default {
	components: {
		ContractGroup
	},
	props: {
		contracts: Object
	},
	data() {
		return {
			showUSD: false,
			showValid: false
		};
	},
	computed: {
		groups() {
			return ['obligationFailed', 'obligationSucceeded',
				'obligationUnresolved'].filter(g => this.contracts && this.contracts[g]);
		},
		alerts() {
			return this.contracts && this.contracts.global ? this.contracts.global : [];
		}
	},
	methods: {
		getCheckboxID(label) {
			return `${this._uid}-${label}`;
		},
		formatSiacoinString(value) {
			if (typeof value === 'string')
				value = new BigNumber(value);

			if (this.showUSD)
				return formatSCToUSDString(value);

			return formatSiacoinString(value, 4);
		}
	}
};
</script>

<style lang="stylus" scoped>
.step-title {
	font-size: 1.2rem;
	color: rgba(0, 0, 0, 0.4);
	margin-bottom: 15px;
}

.contract-groups {
	margin: auto;
	max-width: 800px;
}

.alerts {
	margin-bottom: 30px;

	.alert {
		display: grid;
		position: relative;
		grid-template-columns: 36px 1fr auto;
		padding: 15px;
		border: 2px solid #f7cfcf;
		margin-bottom: 8px;
		border-radius: 4px;
		background: #fbeded;
		box-shadow: 0 3px 10px 1px rgba(0, 0, 0, 0.1);
		color: #bb2222;
		font-size: 0.8rem;
		align-content: center;
		justify-content: center;
		align-items: center;

		&.alert-warning {
			border-color: #f7d7c1;
			background: #fbe8c6;
			color: #bb8722;
		}
	}
}

.filters {
	text-align: right;
	margin-bottom: 15px;

	.control {
		margin-left: 15px;
		margin-bottom: 0;
	}
}

.group-stats {
    margin-bottom: 30px;

	.group-item {
		background: #FFF;
		border-radius: 8px;
		box-shadow: 0 3px 10px 1px rgba(0, 0, 0, 0.1);
	}
}

</style>
