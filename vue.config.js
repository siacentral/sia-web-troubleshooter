const path = require('path');

process.env.VUE_APP_API_BASE_URL = 'https://api.siacentral.com/v2';

module.exports = {
	chainWebpack: config => {
		const svgRule = config.module.rule('svg'),
			types = ['vue-modules', 'vue', 'normal-modules', 'normal'];

		svgRule.uses.clear();
		svgRule
			.use('vue-svg-loader')
			.loader('vue-svg-loader')
			.options({
				svgo: false
			});

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