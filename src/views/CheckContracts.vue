<template>
	<div class="page">
		<transition name="fade" appear>
			<upload-contract-data @parsing="step = 1" @failed="step = 0" @parsed="onContractsParsed" v-if="step < 2" />
		</transition>
		<loader v-if="step === 1" text="Parsing contracts... Please wait..." />
		<transition name="fade" appear>
			<contract-results :contracts="contracts" v-if="step === 2" />
		</transition>
	</div>
</template>

<script>
import UploadContractData from '@/components/contracts/UploadContractData';
import ContractResults from '@/components/contracts/ContractResults';
import Loader from '@/components/Loader';

export default {
	components: {
		ContractResults,
		Loader,
		UploadContractData
	},
	data() {
		return {
			contracts: null,
			step: 0
		};
	},
	methods: {
		onContractsParsed(contracts) {
			try {
				console.log('PARSED', contracts);

				this.contracts = contracts;
				this.step = 2;
			} catch (ex) {
				console.log(ex);
			}
		}
	}
};
</script>
