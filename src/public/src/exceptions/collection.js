var Collection = require('src/common/socketCollection');
var Model = require('./model');

module.exports = Collection.extend({
	url: 'exception',
	model: Model,

	comparator: function(model) {
		return -model.get("clientTime");
	}
});

