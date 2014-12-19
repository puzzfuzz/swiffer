var Model = require('src/common/socketModel');

module.exports = Model.extend({
	urlRoot: 'session',

	parse : function(data) {
		data.id = data.id || data.clientTime;
		return data;
	},

	isActive: function() {
		return !this.isClosed() && !this.isIdle();
	},

	isIdle: function() {
		return (this.get('lastSeen') - this.get('lastIdle') > (5*60*1000));
	},

	isClosed: function() {
		return !!this.get('endTime');
	}
});
