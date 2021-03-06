var Model = require('src/common/socketModel');

module.exports = Model.extend({
	urlRoot: 'exception',

	defaults: {
		active: false
	},

	parse : function(data) {
		data.id = data.id || data.clientTime;
		return data;
	}
});
