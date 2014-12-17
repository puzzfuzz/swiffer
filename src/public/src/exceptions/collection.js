var Collection = require('src/common/collection');
var Model = require('./model');

module.exports = Collection.extend({
	url: 'listExceptions',
	model: Model
});

