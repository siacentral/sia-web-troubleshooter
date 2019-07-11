<template>
	<div class="group">
		<div class="step-title">{{ group.friendlyStatus }} ({{ count }})</div>
		<div class="group-stats group-background">
			<div class="group-item" v-if="group.status === 'obligationFailed'">
				<div class="group-title group-negative">Burnt Collateral</div>
				{{ formatSiacoinString(group.burnt_collateral) }}
			</div>
			<div class="group-item" v-else>
				<div class="group-title">Risked Collateral</div>
				{{ formatSiacoinString(group.risked_collateral) }}
			</div>
			<div class="group-item">
				<div class="group-title">Contract Cost</div>
				{{ formatSiacoinString(group.contract_cost) }}
			</div>
			<div class="group-item group-negative" v-if="group.status === 'obligationFailed'">
				<div class="group-title">Lost Revenue</div>
				{{ formatSiacoinString(group.total_revenue) }}
			</div>
			<div class="group-item" v-else-if="group.status === 'obligationSucceeded'">
				<div class="group-title">Earned Revenue</div>
				{{ formatSiacoinString(group.total_revenue) }}
			</div>
			<div class="group-item" v-else>
				<div class="group-title">Potential Revenue</div>
				{{ formatSiacoinString(group.total_revenue) }}
			</div>
		</div>
		<contract-list :contracts="group.contracts" :group="group.status" :showValid="showValid" />
	</div>
</template>

<script>
import ContractList from '@/components/contracts/ContractList';

import { BigNumber } from 'bignumber.js';
import { formatSiacoinString, formatSCToUSDString } from '@/utils';

export default {
	components: {
		ContractList
	},
	props: {
		group: Object,
		showValid: Boolean
	},
	computed: {
		count() {
			return Array.isArray(this.group.contracts) ? this.group.contracts.length : 0;
		}
	},
	methods: {
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

.group-stats.group-background {
    margin-bottom: 30px;

	.group-item {
		background: #FFF;
		border-radius: 8px;
		box-shadow: 0 3px 10px 1px rgba(0, 0, 0, 0.1);
	}
}
</style>
