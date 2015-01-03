var Model = require('src/common/socketModel');

module.exports = Model.extend({
	urlRoot: 'issue',

	defaults: {
		active: false
	},

	parse : function(data) {
		data.id = data.id || data.message.hashCode();
		return data;
	}
});
