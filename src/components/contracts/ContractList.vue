<template>
	<div class="contracts-list">
		<message-panel v-if="filtered.length === 0" :icon="groupIcon" :text="groupTitle" :subtext="groupText" />
		<div v-else>
			<display-panel class="contract" :extras="contract.alerts" v-for="contract in filtered" :key="contract.obligation_id">
				<div class="contract-title">{{ contract.obligation_id }}</div>
				<div class="group-stats">
					<div class="group-item">
						<div class="group-title">Sia Status</div>
						{{ contract.friendlyStatus }}
					</div>
					<div :class="{ 'group-item': true, 'group-negative': contract.actualStatus === 'obligationFailed' }">
						<div class="group-title" v-if="contract.actualStatus === 'obligationFailed'">Lost Revenue</div>
						<div class="group-title" v-else-if="contract.actualStatus === 'obligationSucceeded'">Earned Revenue</div>
						<div class="group-title" v-else>Potential Revenue</div>
						{{ formatSiacoinString(contract.total_revenue) }}
					</div>
					<div class="group-item group-negative" v-if="contract.actualStatus === 'obligationFailed'">
						<div class="group-title">Burnt Collateral</div>
						{{ formatSiacoinString(contract.missed_proof_outputs[2].value) }}
					</div>
					<div class="group-item" v-else>
						<div class="group-title">Risked Collateral</div>
						{{ formatSiacoinString(contract.risked_collateral) }}
					</div>
					<div class="group-item">
						<div class="group-title">Negotiation Height</div>
						{{ contract.block_height.toString(10) }}
					</div>
					<div class="group-item">
						<div class="group-title">Expiration Height</div>
						{{ contract.expiration_height.toString(10) }}
					</div>
					<div class="group-item">
						<div class="group-title">Proof Deadline</div>
						{{ contract.proof_deadline.toString(10) }}
					</div>
				</div>
			</display-panel>
		</div>
	</div>
</template>

<script>
import MessagePanel from '@/components/MessagePanel';
import DisplayPanel from '@/components/DisplayPanel';

import { BigNumber } from 'bignumber.js';
import { formatSiacoinString, formatSCToUSDString } from '@/utils';

export default {
	components: {
		DisplayPanel,
		MessagePanel
	},
	props: {
		contracts: Array,
		group: String,
		showValid: Boolean
	},
	computed: {
		filtered() {
			console.log(this.group, this.contracts.filter(c => (Array.isArray(c.alerts) && c.alerts.length > 0) || this.showValid));
			return this.contracts.filter(c => (Array.isArray(c.alerts) && c.alerts.length > 0) || this.showValid);
		},
		groupIcon() {
			return 'smile-beam';
		},
		groupText() {
			let friendly;

			switch (this.group.toLowerCase()) {
			case 'obligationfailed':
				friendly = 'Failed';
				break;
			case 'obligationsucceeded':
				friendly = 'Succeeded';
				break;
			default:
				friendly = 'Ongoing';
				break;
			}

			if (this.showValid)
				return `It appears your node has no ${friendly.toLowerCase()} contracts at the moment.`;

			return `It appears that your node has no invalid ${friendly.toLowerCase()} contracts!`;
		},
		groupTitle() {
			let friendly;

			switch (this.group.toLowerCase()) {
			case 'obligationfailed':
				friendly = 'Failed';
				break;
			case 'obligationsucceeded':
				friendly = 'Succeeded';
				break;
			default:
				friendly = 'Ongoing';
				break;
			}

			return `No ${friendly} Contracts Matching Filter`;
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
.contract {
	margin-bottom: 15px;

	.contract-title {
		width: 100%;
		overflow: hidden;
		text-overflow: ellipsis;
		font-size: 1rem;
		margin-bottom: 15px;
	}
}
</style>
