var Model = require('src/common/socketModel');
var _ = require('lodash');

module.exports = Model.extend({
	urlRoot: 'session',

	defaults: {
		sessionEvents: [],
		routes: []
	},

	parse : function(data) {
		data.id = data.id || data.clientTime;

		data.sessionEvents = _(data.routes).map(function(route){
			return {type:'route', event:route}
		}).value();

		return data;
	},

	//Socket.io events: session/<id>:<eventName>
	bindCustom: function(){
		this.ioBind('route', window.socket, this.serverRouteAdded, this);
		this.ioBind('exception', window.socket, this.serverExceptionAdded, this);
		this.ioBind('event', window.socket, this.serverEventAdded, this);
	},

	serverRouteAdded: function(route) {
		console.log('route added');
		this.trigger('route_added');
		this.pushToArray('sessionEvents', {type:'route', event:route.route});
	},

	serverExceptionAdded: function(exception) {
		console.log('exception added');
		this.trigger('exception_added');
		//ensure change:sessionEvents gets triggered
		this.pushToArray('sessionEvents', {type:'exception', event:exception.errorMessage});
	},

	serverEventAdded: function(event) {
		this.trigger('event_added');
		this.pushToArray('sessionEvents', {type:'event', event:event});
	},

	isActive: function() {
		return !this.isClosed() && !this.isIdle();
	},

	isIdle: function() {
		return (this.get('lastSeen') - this.get('lastIdle')) > (5*60*1000);
	},

	isClosed: function() {
		return !!this.get('endTime');
	}
});
