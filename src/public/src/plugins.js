var Backbone = require('backbone');
Backbone.$ = require('jquery');
require('bootstrap');
require('backbone.syphon');
require('backbone-query-parameters');

window.socket = io.connect('/');

window.socket.on('connect', function(){
	console.log('socket connected', arguments);
});

require('backbone.iobind');
require('backbone.iosync');

//require('src/common/sync');

