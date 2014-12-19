var Router = require('src/common/router');
var Radio = require('backbone.radio');

var Collection  = require('./collection');
var IndexRoute  = require('./index/route');

module.exports = Router.extend({
	initialize: function(options) {
		this.container = options.container;
		this.collection = new Collection();
	},

	onBeforeEnter: function() {
		Radio.command('header', 'activate', { path: 'sessions' });
	},

	routes: {
		'sessions'        : 'index'
	},

	index: function() {
		return new IndexRoute({
			container  : this.container,
			collection : this.collection
		});
	}
});
