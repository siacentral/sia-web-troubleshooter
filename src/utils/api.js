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

	return { statusCode: r.status >= 200 && r.status < 300 ? 200 : r.status, body: resp };
}

export async function getSiaAverageSettings() {
	const resp = await sendJSONRequest(`https://api.siacentral.com/v2/hosts/settings/average`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	resp.body.settings = parseSettings(resp.body.settings);

	return resp.body.settings;
}

export async function getSiaConnectability(netaddress) {
	const resp = await sendJSONRequest(`https://api.siacentral.com/v2/troubleshoot/${encodeURIComponent(netaddress)}`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	resp.body.report.external_settings = parseSettings(resp.body.report.external_settings);

	return resp.body.report;
}

export async function getSiaBlock(height) {
	let url = `https://api.siacentral.com/v2/explorer/block`;

	if (height)
		url += `?height=${height}`;

	const resp = await sendJSONRequest(url, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	return resp.body;
}

export async function getSiaCoinPrice() {
	const resp = await sendJSONRequest(`https://api.siacentral.com/v2/market/exchange-rate`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	return resp.body.siacoin;
}

export async function getSCPAverageSettings() {
	const resp = await sendJSONRequest(`https://api.siacentral.com/v2/scprime/hosts/settings/average`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	resp.body.settings = parseSettings(resp.body.settings);

	return resp.body.settings;
}

export async function getSCPConnectability(netaddress) {
	const resp = await sendJSONRequest(`https://api.siacentral.com/v2/scprime/troubleshoot/${encodeURIComponent(netaddress)}`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	resp.body.report.external_settings = parseSettings(resp.body.report.external_settings);

	return resp.body.report;
}

export async function getSCPBlock(height) {
	let url = `https://api.siacentral.com/v2/scprime/explorer/block`;

	if (height)
		url += `?height=${height}`;

	const resp = await sendJSONRequest(url, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	return resp.body;
}

export async function getSCPCoinPrice() {
	const resp = await sendJSONRequest(`https://api.siacentral.com/v2/scprime/market/exchange-rate`, 'GET', null, true);

	if (resp.statusCode !== 200)
		throw new Error(resp.body.message);

	return resp.body.scprimecoin;
}