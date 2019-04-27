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
	const resp = await sendJSONRequest(`${process.env.VUE_APP_API_BASE_URL}/hostdb/average`, 'GET', null, true);

	if (resp.type !== 'success')
		return resp;

	resp.settings = parseSettings(resp.settings);

	return resp;
}

export async function getConnectability(netaddress) {
	const resp = await sendJSONRequest(`${process.env.VUE_APP_API_BASE_URL}/hostdb/checkconnection?netaddress=${netaddress}`, 'GET', null, true);

	if (resp.type !== 'success')
		return resp;

	resp.settings = parseSettings(resp.settings);

	return resp;
}