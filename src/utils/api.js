import { parseSettings } from './parse';

async function sendJSONRequest(url, method, data, excludeToken) {
	let headers = {};

	const r = await fetch(url, {
			method: method,
			mode: 'cors',
			cache: 'no-cache',
			headers: headers,
			body: data ? JSON.stringify(data) : null
		}),
		resp = await r.json();

	return resp;
}

export async function getAverageSettings() {
	const resp = await sendJSONRequest(`${process.env.VUE_APP_API_BASE_URL}/explorer/hosts/average`, 'GET', null, true);

	if (resp.type !== 'success')
		return resp;

	resp.settings = parseSettings(resp.settings);

	return resp;
}

export async function getConnectability(netaddress) {
	netaddress = encodeURIComponent(netaddress);

	const resp = await sendJSONRequest(`${process.env.VUE_APP_API_BASE_URL}/explorer/hosts/checkconnection?netaddress=${netaddress}`, 'GET', null, true);

	if (resp.type !== 'success')
		return resp;

	resp.external_settings = parseSettings(resp.external_settings);

	return resp;
}

export async function getContracts(contracts) {
	const resp = await sendJSONRequest(`${process.env.VUE_APP_API_BASE_URL}/explorer/storage-obligations`, 'POST', {
		contract_ids: contracts
	}, true);

	return resp;
}

export async function getBlock(height) {
	let url = `${process.env.VUE_APP_API_BASE_URL}/explorer/block`;

	if (height)
		url += `?height=${height}`;

	const resp = await sendJSONRequest(url, 'GET', null, true);

	return resp;
}

export function getCoinPrice() {
	return sendJSONRequest('https://api.coingecko.com/api/v3/coins/siacoin?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false', 'GET', null, true);
}