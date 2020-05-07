import { parseSettings } from './parse';
import Store from '@/store';

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

	return { statusCode: r.status >= 200 && r.status < 300 ? 200 : r.status, body: resp };
}

function getBaseURL() {
	if (typeof Store.state.blockchain !== 'string')
		return 'https://api.siacentral.com/v2';

	switch (Store.state.blockchain.toLowerCase()) {
	case 'scprime':
		return 'https://api.siacentral.com/v2/scp';
	default:
		return 'https://api.siacentral.com/v2';
	}
}

export async function getAverageSettings() {
	const resp = await sendJSONRequest(`${getBaseURL()}/hosts/settings/average`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	resp.body.settings = parseSettings(resp.body.settings);

	return resp.body.settings;
}

export async function getConnectability(netaddress) {
	const resp = await sendJSONRequest(`${getBaseURL()}/troubleshoot/${encodeURIComponent(netaddress)}`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	resp.body.report.external_settings = parseSettings(resp.body.report.external_settings);

	return resp.body.report;
}

export async function getBlock(height) {
	let url = `${getBaseURL()}/explorer/block`;

	if (height)
		url += `?height=${height}`;

	const resp = await sendJSONRequest(url, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	return resp.body;
}

export async function getCoinPrice() {
	const resp = await sendJSONRequest(`${getBaseURL()}/market/exchange-rate`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	if (Store.state.blockchain === 'scprime')
		return resp.body.scprimecoin;

	return resp.body.siacoin;
}