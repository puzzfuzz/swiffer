var Route = require('src/common/route');
var RequestCompositeView = require('./composite-view');

module.exports = Route.extend({
	initialize: function(options) {
		this.container = options.container;
		this.collection = options.collection;
	},

	fetch: function() {
		if (this.collection.isNew()) {
			return this.collection.fetch();
		}
	},

	render: function(params) {
		this.view = new RequestCompositeView({
			collection: this.collection
		});

		this.container.show(this.view);
	}
});
