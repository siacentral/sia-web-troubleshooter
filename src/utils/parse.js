import { BigNumber } from 'bignumber.js';

import Store from '@/store';

export function parseNumberString(str, mul, units) {
	const unit = str.replace(/[^a-z]/gi, ''),
		decimalSep = (1.1).toLocaleString().substring(1, 2),
		repRegex = new RegExp(`[^0-9${decimalSep}]`, 'g');

	let num = new BigNumber(str.replace(repRegex, '').replace(decimalSep, '.'), 10),
		found = false;

	if (num.isNaN())
		num = new BigNumber(0);

	if (isNaN(num) || !isFinite(num))
		num = 0;

	if (unit.length === 0)
		return num;

	for (let i = 0; i < units.length; i++) {
		if (unit.toLowerCase() !== units[i].toLowerCase())
			continue;

		mul = Math.pow(mul, i);
		found = true;
		break;
	}

	if (!found)
		throw new Error(`${unit} not found`);

	return num.times(mul);
};

export function parseBlockTimeString(str) {
	/* eslint-disable object-property-newline */
	const multipliers = {
		'm': 4320, 'w': 1008, 'd': 144, 'h': 6,
		'mth': 4320, 'mths': 4320,
		'mon': 4320, 'wk': 1008, 'dy': 144, 'hr': 6,
		'month': 4320, 'week': 1008, 'day': 144, 'hour': 6,
		'months': 4320, 'weeks': 1008, 'days': 144, 'hours': 6
	};

	const unit = str.replace(/[^a-z]/gi, ''),
		num = parseInt(str.replace(/[^0-9]/g, ''), 10);

	if (!multipliers[unit])
		throw new Error(`${unit} not recognized`);

	return Math.floor(num * multipliers[unit]);
}

export function parseSiacoinString(str) {
	return parseNumberString(str, 1000, ['pSC', 'nSC', 'uSC', 'mSC', 'SC', 'KSC', 'MSC', 'GSC', 'TSC']).times(1e12);
}

export function parseCurrencyString(str, currency) {
	currency = !currency || !Store.state.coinPrice[currency] ? Store.state.config.currency : currency;

	const price = Store.state.coinPrice[currency];

	if (price)
		return parseNumberString(str, 1).div(price).times(1e24);

	return parseSiacoinString(str);
}

export function parseByteString(str) {
	try {
		return parseNumberString(str, 1000, ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB']);
	} catch (ex) {}

	return parseNumberString(str, 1024, ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB']);
};

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