define(['jquery', 'underscore',
	'socket.io'
], function($, _, io) {
var _d = {
	msgId: 0,
	waiters: {}
};

App.module("Socket", function(Socket, MyApp, Backbone, Marionette, $, _) {
	// stuff....
});

App.addInitializer(function(options) {
	_d.socket = io.connect("/");

	_d.socket.on('apiResult', function(id, result) {
		console.log("Got an API result", arguments);
		var deferr = _d.waiters[id];
		if (deferr) {
			deferr.resolve(result);
			delete _d.waiters[id];
		}
	});
});

// figure out some kind of event driven provider maybe?
App.API = function API(method, args) {
	var deferr = new $.Deferred(),
		msgId = _d.msgId++;

	_d.waiters[msgId] = deferr;

	_d.socket.emit('api', method, args, msgId);

	return deferr.promise();
};

return App.Socket;

});
