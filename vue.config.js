const path = require('path');

if (process.env.API_ENV === 'local') {
	process.env.VUE_APP_API_BASE_URL = 'http://localhost:8081/api/v1';
	process.env.VUE_APP_API_WEBSOCKET_URL = 'ws://localhost:8081/api/v1';
} else {
	process.env.VUE_APP_API_BASE_URL = 'https://app.siacentral.com/api/v1';
	process.env.VUE_APP_API_WEBSOCKET_URL = 'wss://app.siacentral.com/api/v1';
}

module.exports = {
	chainWebpack: config => {
		const types = ['vue-modules', 'vue', 'normal-modules', 'normal'];

		types.forEach(type => addStyleResource(config.module.rule('stylus').oneOf(type)));
	},

	pwa: {
		name: 'SiaCentral'
	},

	publicPath: undefined,
	outputDir: undefined,
	assetsDir: undefined,
	runtimeCompiler: undefined,
	productionSourceMap: false,
	parallel: undefined,
	css: undefined
};

function addStyleResource(rule) {
	rule.use('style-resource')
		.loader('style-resources-loader')
		.options({
			patterns: [
				path.resolve(__dirname, './src/styles/vars.styl')
			]
		});
}