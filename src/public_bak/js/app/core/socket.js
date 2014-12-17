define(['../../../.', 'underscore',
	'socket.io'
], function($, _, io) {
var _d = {
	msgId: 0,
	waiters: {}
};

$.extend(App, {
	Socket: {
		init: function(options) {
			_d.socket = io.connect("/");

			_d.socket.on('apiResult', function(id, result) {
				console.log("Got an API result", arguments);
				var deferr = _d.waiters[id];
				if (deferr) {
					deferr.resolve(result);
					delete _d.waiters[id];
				}
			});
		}
	},

	API: function(method, args) {
		var deferr = new $.Deferred(),
			msgId = _d.msgId++;

		_d.waiters[msgId] = deferr;

		_d.socket.emit('api', method, args, msgId);

		return deferr.promise();
	}
});

return App.Socket;

});
