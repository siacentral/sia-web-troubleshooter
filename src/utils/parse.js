import { BigNumber } from 'bignumber.js';

export function parseSettings(stats) {
	stats.base_rpc_price = new BigNumber(stats.base_rpc_price);
	stats.collateral = new BigNumber(stats.collateral);
	stats.contract_price = new BigNumber(stats.contract_price);
	stats.download_price = new BigNumber(stats.download_price);
	stats.max_collateral = new BigNumber(stats.max_collateral);
	stats.max_download_batch_size = new BigNumber(stats.max_download_batch_size);
	stats.max_duration = new BigNumber(stats.max_duration);
	stats.max_revise_batch_size = new BigNumber(stats.max_revise_batch_size);
	stats.remaining_storage = new BigNumber(stats.remaining_storage);
	stats.revision_number = new BigNumber(stats.revision_number);
	stats.sector_access_price = new BigNumber(stats.sector_access_price);
	stats.sector_size = new BigNumber(stats.sector_size);
	stats.storage_price = new BigNumber(stats.storage_price);
	stats.total_storage = new BigNumber(stats.total_storage);
	stats.upload_price = new BigNumber(stats.upload_price);
	stats.window_size = new BigNumber(stats.window_size);

	return stats;
}