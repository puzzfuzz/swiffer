var Collection = require('src/common/socketCollection');
var Model = require('./model');

module.exports = Collection.extend({
	url: 'session',
	model: Model,

	comparator: function(model) {
		return -model.get("clientTime");
	}
});