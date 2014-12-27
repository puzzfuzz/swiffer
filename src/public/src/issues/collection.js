var Collection = require('src/common/socketCollection');
var Model = require('./model');

module.exports = Collection.extend({
	url: 'issue',
	model: Model,

	comparator: function(model) {
		return -model.get("recent"); //most recent issues first
	}
});