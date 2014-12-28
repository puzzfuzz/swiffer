var Collection = require('src/common/socketCollection');
var Model = require('./model');

module.exports = Collection.extend({
	url: 'request',
	model: Model,

	comparator: function(model) {
		return -model.get("time"); //highest latency requests first
	}
});