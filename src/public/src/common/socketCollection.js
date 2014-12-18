var Collection = require('./collection');
var _ = require('lodash');

module.exports = Collection.extend({
	socket:window.socket,
	initialize: function () {
		console.log('creating socket collection');
		_.bindAll(this, 'serverCreate', 'collectionCleanup');
		this.ioBind('create', window.socket, this.serverCreate, this);
	},
	serverCreate: function (data) {
		console.log('model added to colleciton from server', data);
		// make sure no duplicates, just in case
		var exists = this.get(data.id);
		if (!exists) {
			data.__isNew = true;
			this.add(data, {parse: true});
		} else {
			data.fromServer = true;
			exists.set(data);
		}
	},
	collectionCleanup: function (callback) {
		this.ioUnbindAll();
		this.each(function (model) {
			model.modelCleanup();
		});
		return this;
	}
});