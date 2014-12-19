var Model = require('src/common/socketModel');

module.exports = Model.extend({
	urlRoot: 'session',

	defaults: {
//		active: false
	},

	parse : function(data) {
		data.id = data.id || data.clientTime;
//		data.active = !data.endTime;

		return data;
	},

	isActive: function() {
		return !this.get('endTime');
	}
});
