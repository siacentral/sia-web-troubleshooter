import BigNumber from 'bignumber.js';

export function getLastItems(arr, n) {
	const len = arr.length,
		min = Math.min(len, n),
		d = len - min;

	let values = [];

	for (let i = len - 1; i >= d; i--)
		values.unshift(arr[i]);

	return values;
};

export function concatUint8Array() {
	let totalSize = 0,
		offset = 0,
		array;

	for (let i = 0; i < arguments.length; i++)
		totalSize += arguments[i].length;

	array = new Uint8Array(totalSize);

	for (let i = 0; i < arguments.length; i++) {
		array.set(arguments[i], offset);

		offset += arguments[i].length;
	}

	return array;
};

/**
 * Splits a Uint8Array into equal segments of n length
 * @param {Uint8Array} arr the array to split
 * @param {Number} len the number of bytes per section
 */
export function splitArray(arr, len) {
	const segments = Math.floor(arr.length / len);
	let ret = [];

	for (let i = 0; i < segments; i++)
		ret.push(arr.slice(len * i, len));

	return ret;
}

export function numberToString(number, divisor, units, decimals) {
	decimals = isFinite(decimals) ? decimals : -1;

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

	let fixed = 0;

	if (decimals === -1)
		fixed = num.dividedBy(mag).toString(10);
	else
		fixed = num.dividedBy(mag).toFixed(decimals);

	return `${fixed} ${unit}`;
};

export function parseNumberString(str, mul, units) {
	const unit = str.replace(/[^a-z]/gi, '');
	let num = new BigNumber(str.replace(/[^0-9.]/g, ''), 10),
		found = false;

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

export function parseByteString(str) {
	return parseNumberString(str, 1000, ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB']).toNumber();
};

export function formatShortTimeString(date) {
	let hours = (date.getHours() % 12).toString(),
		minutes = date.getMinutes().toString(),
		meridian = date.getHours() > 12 ? 'PM' : 'AM';

	if (hours === '0')
		hours = 12;

	if (hours.length === 1)
		hours = '0' + hours.toString();

	if (minutes.length === 1)
		minutes = '0' + minutes.toString();

	return `${hours}:${minutes} ${meridian}`;
}

export function formatByteString(val, dec) {
	return numberToString(val, 1000, ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB'], dec);
};

export function formatSiacoinString(val, dec) {
	if (!isFinite(dec))
		dec = 2;

	if (val.isEqualTo(0))
		return '0 SC';

	return numberToString(val.dividedBy(1e12), 1000, ['pSC', 'nSC', 'uSC', 'mSC', 'SC', 'KSC', 'MSC', 'GSC', 'TSC'], dec);
};

export function formatStoragePriceString(val) {
	return formatSiacoinString(val.times(1e12).times(4320));
};

export function formatSeconds(seconds) {
	const denoms = [31536000, 2628000, 86400, 3600, 60, 1],
		len = denoms.length;

	let time = seconds, str = [];

	for (let i = 0; i < len; i++) {
		const d = denoms[i];

		if (time < d) {
			str.push('00');
			continue;
		}

		const amt = Math.floor(time / d);

		time = time % d;

		str.push(amt < 10 ? `0${amt}` : amt.toString());
	}

	while (str[0] === '00' && str.length > 3)
		str.shift();

	return str.join(':');
}

export function blobToDataURI(blob) {
	console.log(blob);

	return new Promise((resolve, reject) => {
		const reader = new FileReader();

		reader.onerror = reject;
		reader.onload = (e) => resolve(reader.result);

		reader.readAsDataURL(blob);
	});
}

export function sleep(n) {
	return new Promise((resolve) => {
		setTimeout(resolve, n);
	});
}