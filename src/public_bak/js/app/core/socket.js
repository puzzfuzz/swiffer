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
	window.socket = _d.socket;
});

// figure out some kind of event driven provider maybe?
App.API = function API(method, args) {
	var deferr = new $.Deferred(),
		msgId = _d.msgId++;

	_d.socket.emit(method, args, function(err, data) {
		if (err) {
			deferr.reject(err);
		} else {
			deferr.resolve(data);
		}
	});

	return deferr.promise();
};

return App.Socket;

});
