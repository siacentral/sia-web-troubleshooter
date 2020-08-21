import BigNumber from 'bignumber.js';

export function formatFriendlyStatus(status) {
	switch (status.toLowerCase()) {
	case 'obligationsucceeded':
		return 'Successful';
	case 'obligationfailed':
		return 'Failed';
	case 'obligationrejected':
		return 'Rejected';
	case 'obligationunresolved':
		return 'Active';
	}

	return status;
}

export function numberToString(number, divisor, units, decimals) {
	decimals = isFinite(decimals) ? decimals : 2;

	let unit = units[0],
		num = new BigNumber(number),
		mag = new BigNumber(divisor);

	for (let i = 0; i < units.length; i++) {
		unit = units[i];

		if (num.isLessThan(mag)) {
			mag = mag.dividedBy(divisor);
			break;
		}

		mag = mag.multipliedBy(divisor);
	}

	return {
		value: new Intl.NumberFormat([], {
			type: 'decimal',
			minimumFractionDigits: decimals
		}).format(roundNumber(num.dividedBy(mag), decimals)),
		label: unit
	};
};

export function formatBlockTimeString(blocks) {
	if (blocks <= 0)
		return '0 hr';

	const denoms = { 'Month': 4320, 'Week': 1008, 'Day': 144, 'Hour': 6 };

	for (let key in denoms) {
		const d = denoms[key];

		if (blocks < d)
			continue;

		const value = Math.floor(blocks / d);

		if (value > 1)
			key += 's';

		return {
			value: value.toString(),
			label: key
		};
	}

	return {
		value: 0,
		label: 'Hours'
	};
}

export function formatDate(date) {
	return date.toLocaleDateString([], {
		day: 'numeric',
		month: 'short',
		year: 'numeric'
	});
}

export function formatShortDateString(date) {
	return date.toLocaleDateString([], { dateStyle: 'short' });
}

export function formatShortTimeString(date) {
	return date.toLocaleTimeString([], { timeStyle: 'short', hour: '2-digit', minute: '2-digit' });
}

export function formatDuration(sec, short) {
	if (sec <= 0)
		return '0 sec';

	let denoms;

	if (short)
		denoms = { 'd': 86400, 'h': 3600, 'm': 60 };
	else
		denoms = { 'day': 86400, 'hour': 3600, 'min': 60 };

	const keys = Object.keys(denoms), len = keys.length;

	let time = sec, label, i = 1, d;

	for (; i < len; i++) {
		label = keys[i];
		d = denoms[label];

		if (time < d)
			continue;

		const amt = Math.floor(time / d);

		time = time % d;

		return `${amt} ${amt > 1 && !short ? label + 's' : label}`;
	}

	return `< 1 m`;
}

export function formatByteString(val, unit, dec) {
	if (unit === 'decimal')
		return numberToString(val, 1000, ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'], dec);

	return numberToString(val, 1024, ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB'], dec);
};

export function formatByteSpeed(val, unit, dec) {
	if (unit === 'decimal')
		return numberToString(val, 1000, ['B', 'KB/s', 'MB/s', 'GB/s', 'TB/s', 'PB/s'], dec);

	return numberToString(val, 1024, ['B/s', 'KiB/s', 'MiB/s', 'GiB/s', 'TiB/s', 'PiB/s'], dec);
}

export function formatBitSpeed(val, unit, dec) {
	if (unit === 'decimal')
		return numberToString(val, 1000, ['bps', 'Kpbs', 'Mbps', 'Gbps', 'Tbps', 'Pbps'], dec);

	return numberToString(val, 1024, ['bps', 'Kibps', 'Mibps', 'Gibps', 'Tibps', 'Pibps'], dec);
}

export function formatNumber(val, dec) {
	if (!dec)
		dec = 0;

	val = new BigNumber(val);

	return new Intl.NumberFormat([], {
		type: 'decimal',
		minimumFractionDigits: dec
	}).format(roundNumber(val, dec));
}

function roundNumber(val, dec) {
	const str = val.abs().toString(10),
		neg = val.lt(0),
		parts = str.split('.');

	if (parts.length === 1)
		return str;

	let decimals = new BigNumber(`0.${parts[1]}`).abs();

	if (decimals.isNaN() || !decimals.isFinite())
		decimals = new BigNumber(0);

	let num = new BigNumber(parts[0]).plus(decimals.sd(dec)).toNumber();

	if (neg)
		num *= -1;

	return num;
}

function formatSiacoinString(val, dec, unit, factor = 1e24) {
	unit = unit || 'sc';

	if (!isFinite(dec))
		dec = 2;

	if (!val || val.isEqualTo(0)) {
		return {
			value: '0',
			label: unit
		};
	}

	return {
		value: new Intl.NumberFormat([], {
			type: 'decimal',
			minimumFractionDigits: dec,
			maximumFractionDigits: 20
		}).format(roundNumber(val.dividedBy(factor), dec)),
		label: unit
	};
};

function formatCryptoString(val, dec, currency, rate, factor = 1e24) {
	dec = dec || 4;

	if (val.isEqualTo(0) || !rate) {
		return {
			value: '0',
			label: currency.toLowerCase()
		};
	}

	return {
		value: new Intl.NumberFormat([], {
			type: 'decimal',
			minimumFractionDigits: dec,
			maximumFractionDigits: 20
		}).format(roundNumber(val.dividedBy(factor).times(rate), dec)),
		label: currency.toLowerCase()
	};
}

function formatCurrencyString(val, currency, rate, factor = 1e24) {
	const formatter = new Intl.NumberFormat([], { style: 'currency', currency: currency || 'usd', maximumFractionDigits: 20 });

	if (val.isEqualTo(0) || !rate) {
		return {
			value: formatter.format(0),
			label: currency.toLowerCase()
		};
	}

	return {
		value: formatter.format(roundNumber(val.dividedBy(factor).times(rate), 2)),
		label: currency.toLowerCase()
	};
};

const supportedCrypto = [
		'btc',
		'eth',
		'bch',
		'xrp',
		'ltc'
	],
	supportedCurrency = [
		'usd',
		'jpy',
		'eur',
		'gbp',
		'aus',
		'cad',
		'rub',
		'cny'
	];

export function formatSiaDataPriceString(val, dec, unit, currency, rate) {
	if (!val)
		val = new BigNumber(0);

	const byteFactor = unit === 'decimal' ? 1e12 : 1099511627776;

	if (supportedCrypto.indexOf(currency) >= 0 && rate)
		return formatCryptoString(val.times(byteFactor), dec, currency, rate);

	if (supportedCurrency.indexOf(currency) >= 0 && rate)
		return formatCurrencyString(val.times(byteFactor), currency, rate);

	return formatSiacoinString(val.times(byteFactor), dec, currency);
};

export function formatSiaMonthlyPriceString(val, dec, unit, currency, rate) {
	if (!val)
		val = new BigNumber(0);

	const byteFactor = unit === 'decimal' ? 1e12 : 1099511627776;

	if (supportedCrypto.indexOf(currency) >= 0 && rate)
		return formatCryptoString(val.times(byteFactor).times(4320), dec, currency, rate);

	if (supportedCurrency.indexOf(currency) >= 0 && rate)
		return formatCurrencyString(val.times(byteFactor).times(4320), currency, rate);

	return formatSiacoinString(val.times(byteFactor).times(4320), dec, currency);
};

export function formatSiaPriceString(val, dec, currency, rate) {
	if (!val)
		val = new BigNumber(0);

	if (supportedCrypto.indexOf(currency) >= 0 && rate)
		return formatCryptoString(val, dec, currency, rate);

	if (supportedCurrency.indexOf(currency) >= 0 && rate)
		return formatCurrencyString(val, currency, rate);

	return formatSiacoinString(val, dec, currency);
}

export function formatSCPDataPriceString(val, dec, unit, currency, rate) {
	if (!val)
		val = new BigNumber(0);

	const byteFactor = unit === 'decimal' ? 1e12 : 1099511627776;

	if (supportedCrypto.indexOf(currency) >= 0 && rate)
		return formatCryptoString(val.times(byteFactor), dec, currency, rate, 1e27);

	if (supportedCurrency.indexOf(currency) >= 0 && rate)
		return formatCurrencyString(val.times(byteFactor), currency, rate, 1e27);

	return formatSiacoinString(val.times(byteFactor), dec, currency, 1e27);
};

export function formatSCPMonthlyPriceString(val, dec, unit, currency, rate) {
	if (!val)
		val = new BigNumber(0);

	const byteFactor = unit === 'decimal' ? 1e12 : 1099511627776;

	if (supportedCrypto.indexOf(currency) >= 0 && rate)
		return formatCryptoString(val.times(byteFactor).times(4320), dec, currency, rate, 1e27);

	if (supportedCurrency.indexOf(currency) >= 0 && rate)
		return formatCurrencyString(val.times(byteFactor).times(4320), currency, rate, 1e27);

	return formatSiacoinString(val.times(byteFactor).times(4320), dec, currency, 1e27);
};

export function formatSCPPriceString(val, dec, currency, rate) {
	if (!val)
		val = new BigNumber(0);

	if (supportedCrypto.indexOf(currency) >= 0 && rate)
		return formatCryptoString(val, dec, currency, rate, 1e27);

	if (supportedCurrency.indexOf(currency) >= 0 && rate)
		return formatCurrencyString(val, currency, rate, 1e27);

	return formatSiacoinString(val, dec, currency, 1e27);
}