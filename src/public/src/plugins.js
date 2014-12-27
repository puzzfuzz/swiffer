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


//from SO.com/questions/7616461
String.prototype.hashCode = function() {
	var hash = 0, i, chr, len;
	if (this.length == 0) return hash;
	for (i = 0, len = this.length; i < len; i+=1) {
		chr = this.charCodeAt(i);
		hash = ((hash << 5) - hash) + chr;
		hash |= 0; // Convert to 32bit integer
	}
	return  hash;
};

