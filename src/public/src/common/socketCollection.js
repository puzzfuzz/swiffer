var Collection = require('./collection');
var _ = require('lodash');

module.exports = Collection.extend({
	noIoBind: false,
	socket:window.socket,
	initialize: function () {
		console.log('creating socket collection');
		_.bindAll(this, 'serverCreate', 'collectionCleanup');
		if (!this.noIoBind) {
			this.ioBind('create', window.socket, this.serverCreate, this);
			this.bindCustom();
		}
	},
	bindCustom: function() {
		//overwrite me w/ custom event bindings for this model
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